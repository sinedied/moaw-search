import process from 'node:process';
import * as dotenv from 'dotenv';
import fp from 'fastify-plugin'

export interface AppConfig {
  openaiKey: string;
  openaiUrl: string;
}

// The use of fastify-plugin is required to be able
// to export the decorators to the outer scope
export default fp(async (fastify, opts) => {
  dotenv.config();

  const config: AppConfig = {
    openaiKey: process.env.OPENAI_KEY || '',
    openaiUrl: process.env.OPENAI_URL || '',
  };

  if (!config.openaiKey) {
    const message = `OpenAI key is missing!`;
    fastify.log.warn(message);
    throw new Error(message);
  }

  if (!config.openaiUrl) {
    const message = `OpenAI URL is missing!`;
    fastify.log.warn(message);
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
