CREATE TABLE [dbo].[stops_billtomiles]
(
[sbtm_id] [int] NOT NULL IDENTITY(1, 1),
[stp_number] [int] NULL,
[billto_miles_mt_identity] [int] NULL,
[billto_miles_ord_hdrnumber] [int] NOT NULL,
[billto_miles] [int] NOT NULL,
[sbtm_createdate] [datetime] NOT NULL CONSTRAINT [DF_stops_billtomiles_sbtm_createdate] DEFAULT (getdate()),
[sbtm_createby] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_stops_billtomiles_sbtm_createby] DEFAULT (suser_sname()),
[sbtm_lastupdate] [datetime] NULL CONSTRAINT [DF_stops_billtomiles_sbtm_lastupdate] DEFAULT (getdate()),
[sbtm_lastupdateby] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_stops_billtomiles_sbtm_lastupdateby] DEFAULT (suser_sname()),
[sbtm_tolls] [money] NULL,
[sbtm_tolls_mt_identity] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[stops_billtomiles] ADD CONSTRAINT [pk_stops_billtomiles] PRIMARY KEY CLUSTERED ([sbtm_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_stops_billtomiles_stp_number_ord_hdrnumber] ON [dbo].[stops_billtomiles] ([stp_number], [billto_miles_ord_hdrnumber]) INCLUDE ([billto_miles], [billto_miles_mt_identity]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[stops_billtomiles] TO [public]
GO
GRANT INSERT ON  [dbo].[stops_billtomiles] TO [public]
GO
GRANT SELECT ON  [dbo].[stops_billtomiles] TO [public]
GO
GRANT UPDATE ON  [dbo].[stops_billtomiles] TO [public]
GO
