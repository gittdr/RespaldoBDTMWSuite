CREATE TABLE [dbo].[cdcustcode]
(
[cac_id] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ccc_id] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ccc_description] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[plusless] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_cdcustcode_plusless] DEFAULT ('2'),
[ccc_glnumber] [varchar] (66) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ccc_company] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_cdcustcode_ccc_company] DEFAULT ('UNKNOWN'),
[ccc_skt_id] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ccc_revtype1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ccc_id_unique] [int] NOT NULL IDENTITY(1, 1),
[rowsec_rsrv_id] [int] NULL,
[brn_id] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dw_timestamp] [timestamp] NOT NULL,
[INS_TIMESTAMP] [datetime2] (0) NOT NULL CONSTRAINT [DF__cdcustcod__INS_T__38D92380] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cdcustcode] ADD CONSTRAINT [pk_cdcustcode] PRIMARY KEY CLUSTERED ([cac_id], [ccc_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_CDCustcode_timestamp] ON [dbo].[cdcustcode] ([dw_timestamp]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [cdcustcode_INS_TIMESTAMP] ON [dbo].[cdcustcode] ([INS_TIMESTAMP] DESC) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cdcustcode] ADD CONSTRAINT [fk_cdcustcodetoacctcode] FOREIGN KEY ([cac_id]) REFERENCES [dbo].[cdacctcode] ([cac_id])
GO
ALTER TABLE [dbo].[cdcustcode] ADD CONSTRAINT [fk_cdcustcodetosocketprofile] FOREIGN KEY ([ccc_skt_id]) REFERENCES [dbo].[socketprofile] ([skt_id])
GO
GRANT DELETE ON  [dbo].[cdcustcode] TO [public]
GO
GRANT INSERT ON  [dbo].[cdcustcode] TO [public]
GO
GRANT REFERENCES ON  [dbo].[cdcustcode] TO [public]
GO
GRANT SELECT ON  [dbo].[cdcustcode] TO [public]
GO
GRANT UPDATE ON  [dbo].[cdcustcode] TO [public]
GO
