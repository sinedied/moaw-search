import { FastifyBaseLogger } from 'fastify';
import fp from 'fastify-plugin';
import { Configuration, OpenAIApi } from 'openai';
import { AppConfig } from './config.js';
import { anonymizeString } from '../lib/util.js';

// The use of fastify-plugin is required to be able
// to export the decorators to the outer scope
export default fp(async (fastify, opts) => {
  const config = fastify.config;

  fastify.log.info(`Using OpenAI at ${config.openaiApiUrl}`);

  const commonConfigurationOptions = {
    apiKey: config.openaiApiKey,
    baseOptions: {
      headers: {'api-key': config.openaiApiKey},
      params: {
        'api-version': '2023-05-15'
      }
    }
  };

  const completionConfiguration = new Configuration({
    ...commonConfigurationOptions,
    basePath: `${config.openaiApiUrl}/openai/deployments/${config.openaiGptId}`,
  });
  const completion = new OpenAIApi(completionConfiguration);

  const embeddingsConfiguration = new Configuration({
    ...commonConfigurationOptions,
    basePath: `${config.openaiApiUrl}/openai/deployments/${config.openaiAdaId}`,
  });
  const embeddings = new OpenAIApi(embeddingsConfiguration);

  fastify.decorate('openai', new OpenAI(completion, embeddings, config, fastify.log));
}, {
  name: 'openai',
  dependencies: ['config'],
});

// When using .decorate you have to specify added properties for Typescript
declare module 'fastify' {
  export interface FastifyInstance {
    openai: OpenAI
  }
}

export class OpenAI {
  constructor(public readonly completion: OpenAIApi, public readonly embeddings: OpenAIApi, readonly config: AppConfig, private readonly logger: FastifyBaseLogger) {
  }

  async getVectorFromText(prompt: string, user: string): Promise<number[]> {
    const anonymizedUser = anonymizeString(user);

    try {
      const response = await this.embeddings.createEmbedding({
        model: 'text-embedding-ada-002',
        input: prompt,
        user: anonymizedUser,
      });
      return response.data.data[0].embedding;
    } catch (_error: unknown) {
      const error = _error as Error;
      this.logger.error(`OpenAI embeddings error: ${error.message}`);
      return [];
    }
  }
}