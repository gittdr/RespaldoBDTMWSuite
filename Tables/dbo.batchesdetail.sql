CREATE TABLE [dbo].[batchesdetail]
(
[bachnumb] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[invnumb] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[invdate] [datetime] NULL,
[invamnt] [money] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[batchesdetail] ADD CONSTRAINT [pk_batchesdetail] PRIMARY KEY CLUSTERED ([bachnumb], [invnumb]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[batchesdetail] TO [public]
GO
GRANT INSERT ON  [dbo].[batchesdetail] TO [public]
GO
GRANT REFERENCES ON  [dbo].[batchesdetail] TO [public]
GO
GRANT SELECT ON  [dbo].[batchesdetail] TO [public]
GO
GRANT UPDATE ON  [dbo].[batchesdetail] TO [public]
GO
