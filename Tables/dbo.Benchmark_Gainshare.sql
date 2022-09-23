CREATE TABLE [dbo].[Benchmark_Gainshare]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[BenchmarkId] [int] NOT NULL,
[GainshareId] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Benchmark_Gainshare] ADD CONSTRAINT [PK_Benchmark_Gainshare] PRIMARY KEY CLUSTERED ([ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Benchmark_Gainshare] ADD CONSTRAINT [FK_Benchmark_GainShare_Benchmark] FOREIGN KEY ([BenchmarkId]) REFERENCES [dbo].[Benchmark] ([ID])
GO
ALTER TABLE [dbo].[Benchmark_Gainshare] ADD CONSTRAINT [FK_Benchmark_GainShare_Gainshare] FOREIGN KEY ([GainshareId]) REFERENCES [dbo].[Gainshare] ([ID])
GO
GRANT DELETE ON  [dbo].[Benchmark_Gainshare] TO [public]
GO
GRANT INSERT ON  [dbo].[Benchmark_Gainshare] TO [public]
GO
GRANT REFERENCES ON  [dbo].[Benchmark_Gainshare] TO [public]
GO
GRANT SELECT ON  [dbo].[Benchmark_Gainshare] TO [public]
GO
GRANT UPDATE ON  [dbo].[Benchmark_Gainshare] TO [public]
GO
