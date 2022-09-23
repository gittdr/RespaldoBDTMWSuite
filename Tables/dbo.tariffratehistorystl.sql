CREATE TABLE [dbo].[tariffratehistorystl]
(
[trh_number] [int] NOT NULL IDENTITY(1, 1),
[tar_number] [int] NULL,
[trc_number_row] [int] NOT NULL,
[trc_number_col] [int] NOT NULL,
[trh_fromdate] [datetime] NOT NULL,
[trh_todate] [datetime] NOT NULL,
[tra_rate] [money] NULL,
[trh_createdby] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [df_trh_createdbystl] DEFAULT (suser_sname()),
[trh_createddate] [datetime] NULL CONSTRAINT [df_trh_createddatestl] DEFAULT (getdate()),
[trh_updatedby] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trh_updateddate] [datetime] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create trigger [dbo].[ut_tariffratehistorystl] on [dbo].[tariffratehistorystl] for update as
update tariffratehistorystl 
set  trh_updatedby = suser_sname(),
	 trh_updateddate = getdate()
from inserted
where tariffratehistorystl.tar_number = inserted.tar_number and
	  tariffratehistorystl.trc_number_row = inserted.trc_number_row and
	  tariffratehistorystl.trc_number_col = inserted.trc_number_col

GO
ALTER TABLE [dbo].[tariffratehistorystl] ADD CONSTRAINT [PK__tariffratehistor__6A3F4431] PRIMARY KEY CLUSTERED ([trh_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_tariffratehistorystl] ON [dbo].[tariffratehistorystl] ([tar_number], [trc_number_row], [trc_number_col]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tariffratehistorystl] TO [public]
GO
GRANT INSERT ON  [dbo].[tariffratehistorystl] TO [public]
GO
GRANT SELECT ON  [dbo].[tariffratehistorystl] TO [public]
GO
GRANT UPDATE ON  [dbo].[tariffratehistorystl] TO [public]
GO
