CREATE TABLE [dbo].[Benchmark]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[OrderId] [int] NOT NULL,
[BillTo] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Benchmark] [decimal] (12, 6) NOT NULL,
[BenchmarkFound] [bit] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Benchmark] ADD CONSTRAINT [PK_Benchmark] PRIMARY KEY CLUSTERED ([ID]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[Benchmark] TO [public]
GO
GRANT INSERT ON  [dbo].[Benchmark] TO [public]
GO
GRANT REFERENCES ON  [dbo].[Benchmark] TO [public]
GO
GRANT SELECT ON  [dbo].[Benchmark] TO [public]
GO
GRANT UPDATE ON  [dbo].[Benchmark] TO [public]
GO
