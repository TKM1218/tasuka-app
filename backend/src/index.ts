import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import {
  BatchGetCommand,
  DynamoDBDocumentClient,
  GetCommand,
  PutCommand,
  QueryCommand,
} from "@aws-sdk/lib-dynamodb";
import type {
  APIGatewayProxyEventV2,
  APIGatewayProxyStructuredResultV2,
  APIGatewayProxyEventV2WithJWTAuthorizer,
} from "aws-lambda";
import { randomUUID } from "crypto";

const client = DynamoDBDocumentClient.from(new DynamoDBClient({}));

const {
  LISTS_TABLE,
  LIST_MEMBERS_TABLE,
  ITEMS_TABLE,
  NOTIFICATIONS_TABLE,
} = process.env;

type JsonResponse = APIGatewayProxyStructuredResultV2;

const json = (statusCode: number, body: unknown): JsonResponse => {
  return {
    statusCode,
    headers: {
      "content-type": "application/json",
    },
    body: JSON.stringify(body),
  };
};

const getUserId = (
  event: APIGatewayProxyEventV2WithJWTAuthorizer
): string | null => {
  const claims = event.requestContext.authorizer?.jwt?.claims;
  const sub = claims?.sub;
  return typeof sub === "string" ? sub : null;
};

const requireTables = (): string | null => {
  if (!LISTS_TABLE || !LIST_MEMBERS_TABLE || !ITEMS_TABLE) {
    return "Table environment variables are missing.";
  }
  return null;
};

const chunk = <T,>(items: T[], size: number): T[][] => {
  const result: T[][] = [];
  for (let i = 0; i < items.length; i += size) {
    result.push(items.slice(i, i + size));
  }
  return result;
};

type Membership = {
  role?: string;
};

const authorizeListAccess = async (
  listId: string,
  userId: string,
  allowedRoles: string[]
): Promise<{ ok: true } | { ok: false; response: JsonResponse }> => {
  // list_members を必ず参照し、roleも確認する共通認可
  const res = await client.send(
    new GetCommand({
      TableName: LIST_MEMBERS_TABLE,
      Key: {
        listId,
        userId,
      },
    })
  );

  if (!res.Item) {
    return { ok: false, response: json(403, { message: "Forbidden" }) };
  }

  const role = (res.Item as Membership).role ?? "";
  if (!allowedRoles.includes(role)) {
    return { ok: false, response: json(403, { message: "Forbidden" }) };
  }

  return { ok: true };
};

const ensureMember = async (
  listId: string,
  userId: string
): Promise<boolean> => {
  const res = await client.send(
    new GetCommand({
      TableName: LIST_MEMBERS_TABLE,
      Key: {
        listId,
        userId,
      },
    })
  );
  return Boolean(res.Item);
};

export const handler = async (
  event: APIGatewayProxyEventV2WithJWTAuthorizer
): Promise<JsonResponse> => {
  const missing = requireTables();
  if (missing) {
    return json(500, { message: missing });
  }

  const userId = getUserId(event);
  if (!userId) {
    return json(401, { message: "Unauthorized" });
  }

  const method = event.requestContext.http.method;
  const path = event.rawPath;

  if (method === "GET" && path === "/health") {
    return json(200, { ok: true });
  }

  if (method === "GET" && path === "/lists") {
    return handleListIndex(userId);
  }

  if (method === "POST" && path === "/lists") {
    return handleListCreate(userId, event.body ?? "");
  }

  const itemsMatch = path.match(/^\/lists\/([^/]+)\/items$/);
  if (itemsMatch) {
    const listId = itemsMatch[1];
    if (method === "GET") {
      return handleItemsIndex(listId, userId);
    }
    if (method === "POST") {
      return handleItemsCreate(listId, userId, event.body ?? "");
    }
    return json(405, { message: "Method Not Allowed" });
  }

  return json(404, { message: "Not Found" });
};

const handleListIndex = async (userId: string): Promise<JsonResponse> => {
  const res = await client.send(
    new QueryCommand({
      TableName: LIST_MEMBERS_TABLE,
      IndexName: "GSI1",
      KeyConditionExpression: "GSI1PK = :userId",
      ExpressionAttributeValues: {
        ":userId": userId,
      },
    })
  );

  const listIds = (res.Items ?? [])
    .map((item) => item.listId as string)
    .filter(Boolean);

  if (listIds.length === 0) {
    return json(200, { items: [] });
  }

  const chunks = chunk(listIds, 100);
  const lists: Record<string, unknown>[] = [];

  for (const ids of chunks) {
    const batch = await client.send(
      new BatchGetCommand({
        RequestItems: {
          [LISTS_TABLE as string]: {
            Keys: ids.map((id) => ({ listId: id })),
          },
        },
      })
    );
    const found = batch.Responses?.[LISTS_TABLE as string] ?? [];
    lists.push(...found);
  }

  return json(200, { items: lists });
};

const handleListCreate = async (
  userId: string,
  rawBody: string
): Promise<JsonResponse> => {
  let body: { name?: string } = {};
  try {
    body = rawBody ? JSON.parse(rawBody) : {};
  } catch {
    return json(400, { message: "Invalid JSON body" });
  }

  const name = body.name?.trim();
  if (!name) {
    return json(400, { message: "name is required" });
  }

  const now = new Date().toISOString();
  const listId = randomUUID();

  await client.send(
    new PutCommand({
      TableName: LISTS_TABLE,
      Item: {
        listId,
        name,
        ownerUserId: userId,
        createdAt: now,
        updatedAt: now,
      },
    })
  );

  await client.send(
    new PutCommand({
      TableName: LIST_MEMBERS_TABLE,
      Item: {
        listId,
        userId,
        role: "owner",
        createdAt: now,
        GSI1PK: userId,
        GSI1SK: listId,
      },
    })
  );

  return json(201, { listId, name });
};

const handleItemsIndex = async (
  listId: string,
  userId: string
): Promise<JsonResponse> => {
  const auth = await authorizeListAccess(listId, userId, ["owner", "member"]);
  if (!auth.ok) {
    return json(403, { message: "Forbidden" });
  }

  const res = await client.send(
    new QueryCommand({
      TableName: ITEMS_TABLE,
      KeyConditionExpression: "listId = :listId",
      ExpressionAttributeValues: {
        ":listId": listId,
      },
    })
  );

  return json(200, { items: res.Items ?? [] });
};

type ItemInput = {
  type?: string;
  title?: string;
  name?: string;
  memo?: string;
  quantity?: number;
  dueDate?: string;
};

const handleItemsCreate = async (
  listId: string,
  userId: string,
  rawBody: string
): Promise<JsonResponse> => {
  const auth = await authorizeListAccess(listId, userId, ["owner", "member"]);
  if (!auth.ok) {
    return json(403, { message: "Forbidden" });
  }

  let body: ItemInput = {};
  try {
    body = rawBody ? JSON.parse(rawBody) : {};
  } catch {
    return json(400, { message: "Invalid JSON body" });
  }

  const type = body.type?.trim();
  if (!type || (type !== "shopping" && type !== "todo")) {
    return json(400, { message: "type must be shopping or todo" });
  }

  const title = (body.title ?? body.name ?? "").trim();
  if (!title) {
    return json(400, { message: "title or name is required" });
  }

  const now = new Date().toISOString();
  const itemId = randomUUID();

  const item = {
    listId,
    itemId,
    type,
    title,
    name: body.name ?? title,
    memo: body.memo ?? null,
    quantity: body.quantity ?? null,
    status: "open",
    dueDate: body.dueDate ?? null,
    createdBy: userId,
    createdAt: now,
    updatedAt: now,
  };

  await client.send(
    new PutCommand({
      TableName: ITEMS_TABLE,
      Item: item,
    })
  );

  return json(201, item);
};
