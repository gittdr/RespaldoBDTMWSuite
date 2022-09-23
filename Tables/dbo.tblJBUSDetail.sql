CREATE TABLE [dbo].[tblJBUSDetail]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[hdr_SN] [int] NOT NULL,
[did_SN] [int] NOT NULL,
[del_Value] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblJBUSDetail] ADD CONSTRAINT [pk_det_SN] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_tblJBUSDetail_hdrSN] ON [dbo].[tblJBUSDetail] ([hdr_SN]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblJBUSDetail] TO [public]
GO
GRANT INSERT ON  [dbo].[tblJBUSDetail] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblJBUSDetail] TO [public]
GO
GRANT SELECT ON  [dbo].[tblJBUSDetail] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblJBUSDetail] TO [public]
GO
