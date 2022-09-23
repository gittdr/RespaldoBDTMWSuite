CREATE TABLE [dbo].[tariffaccessorialstl]
(
[timestamp] [timestamp] NULL,
[tar_number] [int] NOT NULL,
[trk_number] [int] NOT NULL,
[taa_seq] [int] NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [pk_tar_trk_number] ON [dbo].[tariffaccessorialstl] ([tar_number], [trk_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_trk_number] ON [dbo].[tariffaccessorialstl] ([trk_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tariffaccessorialstl] TO [public]
GO
GRANT INSERT ON  [dbo].[tariffaccessorialstl] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tariffaccessorialstl] TO [public]
GO
GRANT SELECT ON  [dbo].[tariffaccessorialstl] TO [public]
GO
GRANT UPDATE ON  [dbo].[tariffaccessorialstl] TO [public]
GO
