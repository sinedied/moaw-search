import { FastifyPluginAsync } from "fastify"

const example: FastifyPluginAsync = async (fastify, opts): Promise<void> => {
  fastify.get('/liveness', async function (request, reply) {
    reply.code(204).send();
  });

  fastify.get('/readiness', async function (request, reply) {


  });
}

export default example;
