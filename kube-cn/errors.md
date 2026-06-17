## open5gs-5gc

```
[open5gs-5gc-78f6b5c4f8-b7dlz] 2026-06-17T02:08:07.873156640Z  DONE  Compiled successfully in 477ms4:08:07 PM
[open5gs-5gc-78f6b5c4f8-b7dlz] 2026-06-17T02:08:07.873170446Z 
[open5gs-5gc-78f6b5c4f8-b7dlz] 2026-06-17T02:08:07.925325189Z Mongoose: subscribers.ensureIndex({ imsi: 1 }, { unique: true, background: true })
[open5gs-5gc-78f6b5c4f8-b7dlz] 2026-06-17T02:08:07.926456896Z Mongoose: accounts.ensureIndex({ username: 1 }, { unique: true, background: true })
[open5gs-5gc-78f6b5c4f8-b7dlz] 2026-06-17T02:08:07.926699593Z (node:96) DeprecationWarning: collection.ensureIndex is deprecated. Use createIndexes instead.
[open5gs-5gc-78f6b5c4f8-b7dlz] 2026-06-17T02:08:07.926701476Z (Use `node --trace-deprecation ...` to show where the warning was created)
[open5gs-5gc-78f6b5c4f8-b7dlz] 2026-06-17T02:08:07.935933875Z Mongoose: accounts.count({}, {})
[open5gs-5gc-78f6b5c4f8-b7dlz] 2026-06-17T02:08:07.936185308Z (node:96) DeprecationWarning: collection.count is deprecated, and will be removed in a future version. Use Collection.countDocuments or Collection.estimatedDocumentCount instead
[open5gs-5gc-78f6b5c4f8-b7dlz] 2026-06-17T02:08:07.937312547Z > Ready on http://open5gs-5gc-78f6b5c4f8-b7dlz:9999
[open5gs-5gc-78f6b5c4f8-b7dlz] 2026-06-17T02:08:07.945968793Z Mongoose: accounts.findOne({ '$or': [ { username: 'admin' } ] }, { projection: { hash: 0, salt: 0 } })
2026-06-17T02:08:07.967076691Z Connection to 127.0.0.1 27017 port [tcp/*] succeeded!
[open5gs-5gc-78f6b5c4f8-b7dlz] 2026-06-17T02:08:07.998456101Z Mongoose: accounts.insertOne({ roles: [ 'admin' ], _id: ObjectId("6a32018777b92d0060b62b3f"), username: 'admin', salt: '30fe18b3f9c4782fbcd2c1443f661c85d74732e7f25d11d3f0da0a922ed2cc9c', hash: '557120e6282be7da92a85670a6d8405985eea16e42c7532fc7e5cf2087806a3b3c84942cb5dcc667b4bd66230f73725404709a3206cc9e56443ca5ae2df7706545cc8fe8374731f6f4cc1a84d075a46f2a85842a3697931a591f4bf976841fd108d1b9f6a8a2ff583e9a73d8dcf532a4cae1e43d451ca1ec3ed14a8867c09228f182353b19cfd615bd7772b4aa7369a1c983ffea619b42d127e2a480ec3c27f21e3b07d9beaea61d232e7c94a745f3f01eb4ecc5d07e2a797ab8e3e18b1938fd4caa126687be8637b3e9068250fe0fee3a787c091deb03551800bfac43bb320512f3c085c3ba1647c3e37a9f65fef18f6d80a1250cbb76662307d2f7510be3ec4a1b0e035a84bba5b9d7c12bd707d8253827ed9f1e0476685dde1766a51fc6f9b459972cfa7616ebc9aec916db4eb3f542b31466db6a0f316767f52ad2f1da2d30400ca81571aa4b20c78df2ad4587f0811c727a0aea68a77a358db077a536be5ba2c72f80f0d62534c4ba2bcc0034f88cf26386abe713c1a0d2eea1f36aa660602c2c9c30d2afb5f0643ad953c82d80d10425da86c8b748bc07bf419d921d3fed7f2a4f028960897bebc0aee40947054af811aa5b98554c9451ab3bc0a123cd9d491c59756a31bdf22c1fa2d477abdba170f312e44bd031cf30b537efc560c0185879d922809624eafaac257e23db3c8b1b02fcba6f4db2218c9427f49448a7', __v: 0}, { session: null })
[open5gs-5gc-78f6b5c4f8-b7dlz] 2026-06-17T02:08:08.264118016Z net.ipv4.ip_forward = 1
2026-06-17T02:08:08.264631792Z net.ipv6.conf.all.forwarding = 1
[open5gs-5gc-78f6b5c4f8-b7dlz] 2026-06-17T02:08:08.266253772Z SUBSCRIBER_DB=subscriber_db.csv
[open5gs-5gc-78f6b5c4f8-b7dlz] 2026-06-17T02:08:08.370458791Z Reading subscriber data from csv-file.
2026-06-17T02:08:08.370468349Z Added subscriber with Inserted ID : 6a320188b23d2b8f9cf770be
[open5gs-5gc-78f6b5c4f8-b7dlz] 2026-06-17T02:08:08.370470222Z 6a320188b23d2b8f9cf770be
2026-06-17T02:08:08.370471074Z Added subscriber with Inserted ID : 6a320188b23d2b8f9cf770c0
[open5gs-5gc-78f6b5c4f8-b7dlz] 2026-06-17T02:08:08.370472036Z 6a320188b23d2b8f9cf770c0
2026-06-17T02:08:08.890572342Z 2026/06/16 16:08:08.0890: [    1]:  WARNING:       mongoc: Falling back to malloc for counters.
[open5gs-5gc-78f6b5c4f8-b7dlz] 2026-06-17T02:08:08.890809729Z Open5GS daemon v2.7.6
2026-06-17T02:08:08.890817553Z 
[open5gs-5gc-78f6b5c4f8-b7dlz] 2026-06-17T02:08:08.890818866Z 06/16 16:08:08.890: [app] INFO: Configuration: 'open5gs-5gc.yml' (../lib/app/ogs-init.c:144)
[open5gs-5gc-78f6b5c4f8-b7dlz] 2026-06-17T02:08:08.893525675Z Open5GS daemon v2.7.6
2026-06-17T02:08:08.893527519Z 
[open5gs-5gc-78f6b5c4f8-b7dlz] 2026-06-17T02:08:08.893528290Z 06/16 16:08:08.893: [app] INFO: Configuration: 'open5gs-5gc.yml' (../lib/app/ogs-init.c:144)
[open5gs-5gc-78f6b5c4f8-b7dlz] 2026-06-17T02:08:08.894139469Z 06/16 16:08:08.894: [sbi] INFO: NF Service [nnrf-nfm] (../lib/sbi/context.c:1994)
[open5gs-5gc-78f6b5c4f8-b7dlz] 2026-06-17T02:08:08.894140792Z 06/16 16:08:08.894: [sbi] INFO: NF Service [nnrf-disc] (../lib/sbi/context.c:1994)
[open5gs-5gc-78f6b5c4f8-b7dlz] 2026-06-17T02:08:08.894162382Z 06/16 16:08:08.894: [sbi] INFO: nghttp2_server() [http://127.0.0.10]:7777 (../lib/sbi/nghttp2-server.c:439)
2026-06-17T02:08:08.894214210Z 06/16 16:08:08.894: [app] INFO: NRF initialize...done (../src/nrf/app.c:31)
2026-06-17T02:08:08.943469431Z Open5GS daemon v2.7.6
2026-06-17T02:08:08.943474150Z 
[open5gs-5gc-78f6b5c4f8-b7dlz] 2026-06-17T02:08:08.943475272Z 06/16 16:08:08.943: [app] INFO: Configuration: 'open5gs-5gc.yml' (../lib/app/ogs-init.c:144)
2026-06-17T02:08:08.944085329Z 06/16 16:08:08.944: [sbi] INFO: Setup NF EndPoint(addr) [127.0.0.10:7777] (../lib/sbi/context.c:459)
[open5gs-5gc-78f6b5c4f8-b7dlz] 2026-06-17T02:08:08.944222317Z 06/16 16:08:08.944: [sbi] INFO: nghttp2_server() [http://127.0.0.22]:7777 (../lib/sbi/nghttp2-server.c:439)
[open5gs-5gc-78f6b5c4f8-b7dlz] 2026-06-17T02:08:08.944266900Z 06/16 16:08:08.944: [app] INFO: SCP initialize...done (../src/scp/app.c:31)
[open5gs-5gc-78f6b5c4f8-b7dlz] 2026-06-17T02:08:08.944763394Z 06/16 16:08:08.944: [sbi] INFO: Setup NF EndPoint(addr) [127.0.0.22:7777] (../lib/sbi/context.c:2374)
[open5gs-5gc-78f6b5c4f8-b7dlz] 2026-06-17T02:08:08.944777911Z 06/16 16:08:08.944: [nrf] INFO: [62b7be4c-69f1-41f1-85fc-8966e46d48cb] NF registered [Heartbeat:10s] (../src/nrf/nf-sm.c:204)
[open5gs-5gc-78f6b5c4f8-b7dlz] 2026-06-17T02:08:08.944896594Z 06/16 16:08:08.944: [sbi] INFO: [62b7be4c-69f1-41f1-85fc-8966e46d48cb] NF registered [Heartbeat:10s] (../lib/sbi/nf-sm.c:295)
[open5gs-5gc-78f6b5c4f8-b7dlz] 2026-06-17T02:08:08.945082314Z 06/16 16:08:08.945: [nrf] INFO: Setup NF EndPoint(addr) [127.0.0.22:7777] (../src/nrf/nnrf-handler.c:569)
[open5gs-5gc-78f6b5c4f8-b7dlz] 2026-06-17T02:08:08.945083706Z 06/16 16:08:08.945: [nrf] INFO: [62b7e7d2-69f1-41f1-a9c1-4f10c514b5a2] Subscription created until 2026-06-17T16:08:08.945058-10:00 [duration:86400000000,validity:86400.000000] (../src/nrf/nnrf-handler.c:597)
[open5gs-5gc-78f6b5c4f8-b7dlz] 2026-06-17T02:08:08.945135143Z 06/16 16:08:08.945: [nrf] INFO: Setup NF EndPoint(addr) [127.0.0.22:7777] (../src/nrf/nnrf-handler.c:569)
[open5gs-5gc-78f6b5c4f8-b7dlz] 2026-06-17T02:08:08.945136576Z 06/16 16:08:08.945: [nrf] INFO: [62b7eaca-69f1-41f1-a9c1-4f10c514b5a2] Subscription created until 2026-06-17T16:08:08.945124-10:00 [duration:86400000000,validity:86400.000000] (../src/nrf/nnrf-handler.c:597)
[open5gs-5gc-78f6b5c4f8-b7dlz] 2026-06-17T02:08:08.945150071Z 06/16 16:08:08.945: [nrf] INFO: Setup NF EndPoint(addr) [127.0.0.22:7777] (../src/nrf/nnrf-handler.c:569)
2026-06-17T02:08:08.945150963Z 06/16 16:08:08.945: [nrf] INFO: [62b7eb88-69f1-41f1-a9c1-4f10c514b5a2] Subscription created until 2026-06-17T16:08:08.945142-10:00 [duration:86400000000,validity:86400.000000] (../src/nrf/nnrf-handler.c:597)
[open5gs-5gc-78f6b5c4f8-b7dlz] 2026-06-17T02:08:08.945166652Z 06/16 16:08:08.945: [nrf] INFO: Setup NF EndPoint(addr) [127.0.0.22:7777] (../src/nrf/nnrf-handler.c:569)
2026-06-17T02:08:08.945167804Z 06/16 16:08:08.945: [nrf] INFO: [62b7ec1e-69f1-41f1-a9c1-4f10c514b5a2] Subscription created until 2026-06-17T16:08:08.945157-10:00 [duration:86400000000,validity:86400.000000] (../src/nrf/nnrf-handler.c:597)
[open5gs-5gc-78f6b5c4f8-b7dlz] 2026-06-17T02:08:08.945178575Z 06/16 16:08:08.945: [nrf] INFO: Setup NF EndPoint(addr) [127.0.0.22:7777] (../src/nrf/nnrf-handler.c:569)
2026-06-17T02:08:08.945179336Z 06/16 16:08:08.945: [nrf] INFO: [62b7ecb4-69f1-41f1-a9c1-4f10c514b5a2] Subscription created until 2026-06-17T16:08:08.945172-10:00 [duration:86400000000,validity:86400.000000] (../src/nrf/nnrf-handler.c:597)
[open5gs-5gc-78f6b5c4f8-b7dlz] 2026-06-17T02:08:08.945192992Z 06/16 16:08:08.945: [nrf] INFO: Setup NF EndPoint(addr) [127.0.0.22:7777] (../src/nrf/nnrf-handler.c:569)
2026-06-17T02:08:08.945193713Z 06/16 16:08:08.945: [nrf] INFO: [62b7ed4a-69f1-41f1-a9c1-4f10c514b5a2] Subscription created until 2026-06-17T16:08:08.945187-10:00 [duration:86400000000,validity:86400.000000] (../src/nrf/nnrf-handler.c:597)
[open5gs-5gc-78f6b5c4f8-b7dlz] 2026-06-17T02:08:08.945261330Z 06/16 16:08:08.945: [nrf] INFO: Setup NF EndPoint(addr) [127.0.0.22:7777] (../src/nrf/nnrf-handler.c:569)
[open5gs-5gc-78f6b5c4f8-b7dlz] 2026-06-17T02:08:08.945267311Z 06/16 16:08:08.945: [nrf] INFO: [62b7ef84-69f1-41f1-a9c1-4f10c514b5a2] Subscription created until 2026-06-17T16:08:08.945244-10:00 [duration:86400000000,validity:86400.000000] (../src/nrf/nnrf-handler.c:597)
2026-06-17T02:08:08.945269205Z 06/16 16:08:08.945: [nrf] INFO: Setup NF EndPoint(addr) [127.0.0.22:7777] (../src/nrf/nnrf-handler.c:569)
[open5gs-5gc-78f6b5c4f8-b7dlz] 2026-06-17T02:08:08.945270357Z 06/16 16:08:08.945: [nrf] INFO: [62b7eff2-69f1-41f1-a9c1-4f10c514b5a2] Subscription created until 2026-06-17T16:08:08.945255-10:00 [duration:86400000000,validity:86400.000000] (../src/nrf/nnrf-handler.c:597)
2026-06-17T02:08:08.945276388Z 06/16 16:08:08.945: [nrf] INFO: Setup NF EndPoint(addr) [127.0.0.22:7777] (../src/nrf/nnrf-handler.c:569)
[open5gs-5gc-78f6b5c4f8-b7dlz] 2026-06-17T02:08:08.945277250Z 06/16 16:08:08.945: [nrf] INFO: [62b7f088-69f1-41f1-a9c1-4f10c514b5a2] Subscription created until 2026-06-17T16:08:08.945270-10:00 [duration:86400000000,validity:86400.000000] (../src/nrf/nnrf-handler.c:597)
[open5gs-5gc-78f6b5c4f8-b7dlz] 2026-06-17T02:08:08.945338295Z 06/16 16:08:08.945: [sbi] INFO: Setup NF EndPoint(addr) [127.0.0.10:7777] (../lib/sbi/nnrf-handler.c:955)
2026-06-17T02:08:08.945345438Z 06/16 16:08:08.945: [sbi] INFO: [62b7e7d2-69f1-41f1-a9c1-4f10c514b5a2] Subscription created until 2026-06-17T16:08:08.945058-10:00 [duration:86400000000,validity:86400.000000,patch:43200.000000] (../lib/sbi/nnrf-handler.c:874)
[open5gs-5gc-78f6b5c4f8-b7dlz] 2026-06-17T02:08:08.945351890Z 06/16 16:08:08.945: [sbi] INFO: Setup NF EndPoint(addr) [127.0.0.10:7777] (../lib/sbi/nnrf-handler.c:955)
[open5gs-5gc-78f6b5c4f8-b7dlz] 2026-06-17T02:08:08.945354044Z 06/16 16:08:08.945: [sbi] INFO: [62b7eaca-69f1-41f1-a9c1-4f10c514b5a2] Subscription created until 2026-06-17T16:08:08.945124-10:00 [duration:86400000000,validity:86400.000000,patch:43200.000000] (../lib/sbi/nnrf-handler.c:874)
[open5gs-5gc-78f6b5c4f8-b7dlz] 2026-06-17T02:08:08.945388579Z 06/16 16:08:08.945: [sbi] INFO: Setup NF EndPoint(addr) [127.0.0.10:7777] (../lib/sbi/nnrf-handler.c:955)
[open5gs-5gc-78f6b5c4f8-b7dlz] 2026-06-17T02:08:08.945389401Z 06/16 16:08:08.945: [sbi] INFO: [62b7eb88-69f1-41f1-a9c1-4f10c514b5a2] Subscription created until 2026-06-17T16:08:08.945142-10:00 [duration:86400000000,validity:86400.000000,patch:43200.000000] (../lib/sbi/nnrf-handler.c:874)
[open5gs-5gc-78f6b5c4f8-b7dlz] 2026-06-17T02:08:08.945395653Z 06/16 16:08:08.945: [sbi] INFO: Setup NF EndPoint(addr) [127.0.0.10:7777] (../lib/sbi/nnrf-handler.c:955)
2026-06-17T02:08:08.945396604Z 06/16 16:08:08.945: [sbi] INFO: [62b7ec1e-69f1-41f1-a9c1-4f10c514b5a2] Subscription created until 2026-06-17T16:08:08.945157-10:00 [duration:86400000000,validity:86400.000000,patch:43200.000000] (../lib/sbi/nnrf-handler.c:874)
[open5gs-5gc-78f6b5c4f8-b7dlz] 2026-06-17T02:08:08.945447630Z 06/16 16:08:08.945: [sbi] INFO: Setup NF EndPoint(addr) [127.0.0.10:7777] (../lib/sbi/nnrf-handler.c:955)
2026-06-17T02:08:08.945448933Z 06/16 16:08:08.945: [sbi] INFO: [62b7ecb4-69f1-41f1-a9c1-4f10c514b5a2] Subscription created until 2026-06-17T16:08:08.945172-10:00 [duration:86400000000,validity:86400.000000,patch:43200.000000] (../lib/sbi/nnrf-handler.c:874)
[open5gs-5gc-78f6b5c4f8-b7dlz] 2026-06-17T02:08:08.945474240Z 06/16 16:08:08.945: [sbi] INFO: Setup NF EndPoint(addr) [127.0.0.10:7777] (../lib/sbi/nnrf-handler.c:955)
[open5gs-5gc-78f6b5c4f8-b7dlz] 2026-06-17T02:08:08.945475152Z 06/16 16:08:08.945: [sbi] INFO: [62b7ed4a-69f1-41f1-a9c1-4f10c514b5a2] Subscription created until 2026-06-17T16:08:08.945187-10:00 [duration:86400000000,validity:86400.000000,patch:43200.000000] (../lib/sbi/nnrf-handler.c:874)
[open5gs-5gc-78f6b5c4f8-b7dlz] 2026-06-17T02:08:08.945485722Z 06/16 16:08:08.945: [sbi] INFO: Setup NF EndPoint(addr) [127.0.0.10:7777] (../lib/sbi/nnrf-handler.c:955)
2026-06-17T02:08:08.945486463Z 06/16 16:08:08.945: [sbi] INFO: [62b7ef84-69f1-41f1-a9c1-4f10c514b5a2] Subscription created until 2026-06-17T16:08:08.945244-10:00 [duration:86400000000,validity:86400.000000,patch:43200.000000] (../lib/sbi/nnrf-handler.c:874)
[open5gs-5gc-78f6b5c4f8-b7dlz] 2026-06-17T02:08:08.945512452Z 06/16 16:08:08.945: [sbi] INFO: Setup NF EndPoint(addr) [127.0.0.10:7777] (../lib/sbi/nnrf-handler.c:955)
[open5gs-5gc-78f6b5c4f8-b7dlz] 2026-06-17T02:08:08.945513194Z 06/16 16:08:08.945: [sbi] INFO: [62b7eff2-69f1-41f1-a9c1-4f10c514b5a2] Subscription created until 2026-06-17T16:08:08.945255-10:00 [duration:86400000000,validity:86400.000000,patch:43200.000000] (../lib/sbi/nnrf-handler.c:874)
2026-06-17T02:08:08.945577705Z 06/16 16:08:08.945: [sbi] INFO: Setup NF EndPoint(addr) [127.0.0.10:7777] (../lib/sbi/nnrf-handler.c:955)
[open5gs-5gc-78f6b5c4f8-b7dlz] 2026-06-17T02:08:08.945579228Z 06/16 16:08:08.945: [sbi] INFO: [62b7f088-69f1-41f1-a9c1-4f10c514b5a2] Subscription created until 2026-06-17T16:08:08.945270-10:00 [duration:86400000000,validity:86400.000000,patch:43200.000000] (../lib/sbi/nnrf-handler.c:874)
[open5gs-5gc-78f6b5c4f8-b7dlz] 2026-06-17T02:08:08.994426963Z Open5GS daemon v2.7.6
[open5gs-5gc-78f6b5c4f8-b7dlz] 2026-06-17T02:08:08.994435278Z 
[open5gs-5gc-78f6b5c4f8-b7dlz] 2026-06-17T02:08:08.994436380Z 06/16 16:08:08.994: [app] INFO: Configuration: 'open5gs-5gc.yml' (../lib/app/ogs-init.c:144)
[open5gs-5gc-78f6b5c4f8-b7dlz] 2026-06-17T02:08:09.007143593Z 06/16 16:08:09.007: [pfcp] INFO: pfcp_server() [127.0.0.7]:8805 (../lib/pfcp/path.c:30)
[open5gs-5gc-78f6b5c4f8-b7dlz] 2026-06-17T02:08:09.007146829Z 06/16 16:08:09.007: [gtp] INFO: gtp_server() [0.0.0.0]:2152 (../lib/gtp/path.c:30)
[open5gs-5gc-78f6b5c4f8-b7dlz] 2026-06-17T02:08:09.007335143Z 06/16 16:08:09.007: [app] INFO: UPF initialize...done (../src/upf/app.c:31)
[open5gs-5gc-78f6b5c4f8-b7dlz] 2026-06-17T02:08:09.046882381Z Open5GS daemon v2.7.6
[open5gs-5gc-78f6b5c4f8-b7dlz] 2026-06-17T02:08:09.046887090Z 
[open5gs-5gc-78f6b5c4f8-b7dlz] 2026-06-17T02:08:09.046893371Z 06/16 16:08:09.046: [app] INFO: Configuration: 'open5gs-5gc.yml' (../lib/app/ogs-init.c:144)
[open5gs-5gc-78f6b5c4f8-b7dlz] 2026-06-17T02:08:09.061175425Z 06/16 16:08:09.061: [sbi] INFO: Setup NF EndPoint(addr) [127.0.0.22:7777] (../lib/sbi/context.c:507)
2026-06-17T02:08:09.061197166Z 06/16 16:08:09.061: [metrics] INFO: metrics_server() [http://127.0.0.4]:9090 (../lib/metrics/prometheus/context.c:300)
[open5gs-5gc-78f6b5c4f8-b7dlz] 2026-06-17T02:08:09.068930426Z 06/16 16:08:09.068: [app] INFO: Polling freeDiameter stats every 60000000 usecs (../lib/diameter/common/stats.c:77)
[open5gs-5gc-78f6b5c4f8-b7dlz] 2026-06-17T02:08:09.068934604Z 06/16 16:08:09.068: [gtp] INFO: gtp_server() [127.0.0.4]:2123 (../lib/gtp/path.c:30)
[open5gs-5gc-78f6b5c4f8-b7dlz] 2026-06-17T02:08:09.068951075Z 06/16 16:08:09.068: [sock] ERROR: socket bind(2) [127.0.0.4]:2152 failed (98:Address already in use) (../lib/core/ogs-socket.c:114)
2026-06-17T02:08:09.068955623Z 06/16 16:08:09.068: [sock] ERROR: udp_server() [127.0.0.4]:2152 failed (98:Address already in use) (../lib/core/ogs-udp.c:67)
[open5gs-5gc-78f6b5c4f8-b7dlz] 2026-06-17T02:08:09.068956856Z 06/16 16:08:09.068: [app] ERROR: Failed to initialize SMF (../src/smf/app.c:28)
2026-06-17T02:08:09.068957667Z 06/16 16:08:09.068: [app] FATAL: Open5GS initialization failed. Aborted (../src/main.c:224)
[open5gs-5gc-78f6b5c4f8-b7dlz] 2026-06-17T02:08:09.069233967Z 06/16 16:08:09.069: [core] FATAL: child_main: Assertion `out_return_code == 0' failed. (../tests/common/application.c:120)
2026-06-17T02:08:09.069273481Z 06/16 16:08:09.069: [core] FATAL: backtrace() returned 5 addresses (../lib/core/ogs-abort.c:37)
[open5gs-5gc-78f6b5c4f8-b7dlz] 2026-06-17T02:08:09.069313587Z 5gc(+0x18b29) [0x64de40a2ab29]
[open5gs-5gc-78f6b5c4f8-b7dlz] 2026-06-17T02:08:09.069315129Z /open5gs/build/tests/app/../../lib/core/libogscore.so.2(+0x119a3) [0x729ccfd399a3]
[open5gs-5gc-78f6b5c4f8-b7dlz] 2026-06-17T02:08:09.069315921Z /lib/x86_64-linux-gnu/libc.so.6(+0x94ac3) [0x729ccf8a4ac3]
[open5gs-5gc-78f6b5c4f8-b7dlz] 2026-06-17T02:08:09.069316522Z /lib/x86_64-linux-gnu/libc.so.6(+0x1268d0) [0x729ccf9368d0]
```