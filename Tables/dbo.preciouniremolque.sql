CREATE TABLE [dbo].[preciouniremolque]
(
[renglon] [int] NOT NULL,
[precio] [decimal] (4, 2) NOT NULL,
[contrato] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[preciouniremolque] ADD CONSTRAINT [pkpreciouniremo] PRIMARY KEY NONCLUSTERED ([renglon]) ON [PRIMARY]
GO
