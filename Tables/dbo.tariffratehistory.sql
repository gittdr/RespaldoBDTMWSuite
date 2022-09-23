CREATE TABLE [dbo].[tariffratehistory]
(
[trh_number] [int] NOT NULL IDENTITY(1, 1),
[tar_number] [int] NULL,
[trc_number_row] [int] NOT NULL,
[trc_number_col] [int] NOT NULL,
[trh_fromdate] [datetime] NOT NULL,
[trh_todate] [datetime] NOT NULL,
[tra_rate] [money] NULL,
[trh_createdby] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [df_trh_createdby] DEFAULT (suser_sname()),
[trh_createddate] [datetime] NULL CONSTRAINT [df_trh_createddate] DEFAULT (getdate()),
[trh_updatedby] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trh_updateddate] [datetime] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create trigger [dbo].[ut_tariffratehistory] on [dbo].[tariffratehistory] for update as
update tariffratehistory 
set  trh_updatedby = suser_sname(),
	 trh_updateddate = getdate()
from inserted
where tariffratehistory.tar_number = inserted.tar_number and
	  tariffratehistory.trc_number_row = inserted.trc_number_row and
	  tariffratehistory.trc_number_col = inserted.trc_number_col

GO
ALTER TABLE [dbo].[tariffratehistory] ADD CONSTRAINT [PK__tariffratehistor__666EB34D] PRIMARY KEY CLUSTERED ([trh_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_tariffratehistory] ON [dbo].[tariffratehistory] ([tar_number], [trc_number_row], [trc_number_col]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tariffratehistory] TO [public]
GO
GRANT INSERT ON  [dbo].[tariffratehistory] TO [public]
GO
GRANT SELECT ON  [dbo].[tariffratehistory] TO [public]
GO
GRANT UPDATE ON  [dbo].[tariffratehistory] TO [public]
GO
