import process from 'node:process';
import path from 'node:path';
import * as dotenv from 'dotenv';
import fp from 'fastify-plugin'

export interface AppConfig {
  qdHost: string;
  qdPort: string;
  redisHost: string;
  redisKey: string;
  acsApiUrl: string;
  acsApiKey: string;
  openaiApiUrl: string;
  openaiApiKey: string;
  openaiAdaId: string;
  openaiGptId: string;
}

// The use of fastify-plugin is required to be able
// to export the decorators to the outer scope
export default fp(async (fastify, opts) => {
  const envPath = path.resolve(process.cwd(), '../../.env');

  console.log(`Loading .env config from ${envPath}...`);
  dotenv.config({ path: envPath });

  const config: AppConfig = {
    qdHost: process.env.QD_HOST || 'localhost',
    qdPort: process.env.QD_PORT || '6333',
    redisHost: process.env.REDIS_HOST || '',
    redisKey: process.env.REDIS_KEY || '',
    acsApiUrl: process.env.ACS_API_URL || '',
    acsApiKey: process.env.ACS_API_KEY || '',
    openaiApiKey: process.env.OPENAI_API_KEY || '',
    openaiApiUrl: process.env.OPENAI_API_URL || '',
    openaiAdaId: process.env.OPENAI_ADA_ID || 'text-embedding-ada-002',
    openaiGptId: process.env.OPENAI_GPT_ID || 'gpt-35-turbo',
  };

  if (!config.acsApiUrl) {
    const message = `ACS_API_URL is missing!`;
    fastify.log.error(message);
    throw new Error(message);
  }

  if (!config.acsApiKey) {
    const message = `ACS_API_KEY is missing!`;
    fastify.log.error(message);
    throw new Error(message);
  }

  if (!config.openaiApiKey) {
    const message = `OPENAI_API_KEY key is missing!`;
    fastify.log.error(message);
    throw new Error(message);
  }

  if (!config.openaiApiUrl) {
    const message = `OPENAI_API_URL is missing!`;
    fastify.log.error(message);
    throw new Error(message);
  }

  fastify.decorate('config', config);
}, {
  name: 'config',
});

// When using .decorate you have to specify added properties for Typescript
declare module 'fastify' {
  export interface FastifyInstance {
    config: AppConfig;
  }
}
