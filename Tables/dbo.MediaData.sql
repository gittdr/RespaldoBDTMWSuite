CREATE TABLE [dbo].[MediaData]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[FileName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Packet] [int] NULL,
[Total] [int] NULL,
[Finished] [bit] NULL,
[DateCreated] [datetime] NULL,
[DateReceived] [datetime] NULL,
[Data] [varbinary] (max) NULL,
[DataFormat] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Size] [int] NULL,
[AssetName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_number] [int] NULL,
[stp_number] [int] NULL,
[ExtraData] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MediaData] ADD CONSTRAINT [PK_MediaData] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
