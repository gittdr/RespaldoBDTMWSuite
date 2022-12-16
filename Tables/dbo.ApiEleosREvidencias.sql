CREATE TABLE [dbo].[ApiEleosREvidencias]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[load_number] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[download_url] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[files_name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fecha] [datetime] NULL CONSTRAINT [DF__ApiEleosR__fecha__675F083F] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ApiEleosREvidencias] ADD CONSTRAINT [PK__ApiEleos__3213E83F4376A80C] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
