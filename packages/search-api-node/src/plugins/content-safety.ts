import fp from 'fastify-plugin';

// The use of fastify-plugin is required to be able
// to export the decorators to the outer scope
export default fp(async (fastify, opts) => {
  const config = fastify.config;

  fastify.log.info(`Using Azure Content Safety at ${config.acsApiUrl}`);

  // TODO: No JS SDK for ACS yet
  // fastify.decorate('contentSafety', );
}, {
  name: 'contentSafety',
  dependencies: ['config'],
});

// When using .decorate you have to specify added properties for Typescript
declare module 'fastify' {
  export interface FastifyInstance {
    contentSafety: string;
  }
}
