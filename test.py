# system constants
R = 2**1040

# test vectors
N = 0xf2de7c5516d3335bbeaa6bfdf4f1afa75b8cb99f24bedc54dac854782f95a59692b0a08540a6146ccc19987a058c424f3b742c688e4afbd0317bd23102d03feed7a98f93a0e8a7abd3671f433bf499ae8ed9f85d414ea6e60bf35412452baeeba2f4edcf2f6289cb90b3f991133598db5c8ce6da416809cfd788f313b889530b
A = 0xe3d4a95d7ea8edde23d1d1e3dd90de3607474fcfddac4f0332365372265210ad26b8ddfac5d5fc5245570348e1e2ce95147c14a994f6f0897277152ce39978de2e7170e9147c8cb19d75f642b36c144e86744ac52ec64fe4e26f4d7a85460eaac72dd0c9551e1aa504dffb070b70c897a75060a083ac475ed0db52d31c87490b
B = 0xc8473e97fa6ffcbe60fa2c47985077b37e732a3bfe6b8af9f4f0a481c7ab46aaaf3fd58ceaf5ce92c4d446fc9099bd580a25774a4eab7b7590f9b857a61c7d890c0ddff5a8e5c4b838eb03eca2b19d6d9e7bd97ae5e21c18a61421b06a574c8837c3cfa4d717d11469b4715c67d3b522531672187c6c29bc8a1e09a8c16cfce7

# expected answers
D = 0x08ab5cd54231dfcea5cf727b3ba9311280dd0ce61e08866058f5bc2826528922bcb08543798c55153f2cee6a0ebf7817cba3cc9403c687cfcc946e293b32238626df6e3ebe0fe9a79cd099496ed74a131ef5ee71eb000559a543e8232dfbe08d4ff196aedb6490a3a2cc95dc6d9f8cca13b779e3bc69412e5633e15aae0a1954
E = 0x088254b9a8562550f6123afa5a9b08e77c1c5feafbe8a735720492a9f3f18c53e39ac25c445782daac89290b3d473c0f0b52d58da5a7ec4d65b55ce89533d8d778a7b357a714d42796629005b54f438a946295b0b69735fcaecec8dd62f6c9c3cde3afdf07d40142ace285dedc267547952f0fb957d577be6752b8bf10e7a4f3
F = 0x3ad22dbcc5ef6f489ea82ebb4ba667123288e6ddc83e4db4e8c8f1f2156b8140c6d3bc1790d8d323b4b84379795d56015551229686621b73a565366d4e9d8d74b66333bb306703b679f2a5be50bb4e20e36f7cefa1bae9a718cef8a0dd65feda8a3633eb9f14a465c1b1ba7156aad5952896aff56b1bd911f120b41034305a7e

# validate the answers
# D = A * B * R^(-1) mod N
# E = A * R mod N
# F = A * R^(-1) mod N
assert 0 <= D < N and 0 == (A*B - D*R) % N
assert 0 <= E < N and 0 == (A*R - E) % N
assert 0 <= F < N and 0 == (A - F*R) % N

print('{:0256x}'.format(D))
print('{:0256x}'.format(E))
print('{:0256x}'.format(F))
