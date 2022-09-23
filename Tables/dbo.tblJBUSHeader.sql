CREATE TABLE [dbo].[tblJBUSHeader]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[hdr_MCSN] [int] NOT NULL,
[hdr_Tractor] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[hdr_Driver] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hdr_DateTime] [datetime] NOT NULL,
[did_Type] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblJBUSHeader] ADD CONSTRAINT [pk_hdr_SN] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [dk_tblJBUSHeader_TractorDateTimeType] ON [dbo].[tblJBUSHeader] ([hdr_Tractor], [hdr_DateTime], [did_Type]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblJBUSHeader] TO [public]
GO
GRANT INSERT ON  [dbo].[tblJBUSHeader] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblJBUSHeader] TO [public]
GO
GRANT SELECT ON  [dbo].[tblJBUSHeader] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblJBUSHeader] TO [public]
GO
