CREATE TABLE [dbo].[cod_status]
(
[ord_hdrnumber] [int] NOT NULL,
[status_code] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[updatedby] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[updateddate] [datetime] NOT NULL,
[rowchgts] [timestamp] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cod_status] ADD CONSTRAINT [PK__cod_stat__F01A75DCED258F21] PRIMARY KEY CLUSTERED ([ord_hdrnumber], [updateddate]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[cod_status] TO [public]
GO
GRANT INSERT ON  [dbo].[cod_status] TO [public]
GO
GRANT REFERENCES ON  [dbo].[cod_status] TO [public]
GO
GRANT SELECT ON  [dbo].[cod_status] TO [public]
GO
GRANT UPDATE ON  [dbo].[cod_status] TO [public]
GO
