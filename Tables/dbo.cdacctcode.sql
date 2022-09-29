CREATE TABLE [dbo].[cdacctcode]
(
[cac_id] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cac_description] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfb_xfacetype] [int] NULL,
[cac_vendor_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_cdacctcode_cac_vendor_code] DEFAULT ('UNKNOWN'),
[cac_glnumber] [varchar] (66) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cac_company] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_cdacctcode_cac_company] DEFAULT ('UNKNOWN'),
[skt_id] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dw_timestamp] [timestamp] NOT NULL,
[INS_TIMESTAMP] [datetime2] (0) NOT NULL CONSTRAINT [DF__cdacctcod__INS_T__37E4FF47] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cdacctcode] ADD CONSTRAINT [pk_cdacctcode] PRIMARY KEY CLUSTERED ([cac_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_CDAcctcode_timestamp] ON [dbo].[cdacctcode] ([dw_timestamp]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [cdacctcode_INS_TIMESTAMP] ON [dbo].[cdacctcode] ([INS_TIMESTAMP] DESC) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[cdacctcode] TO [public]
GO
GRANT INSERT ON  [dbo].[cdacctcode] TO [public]
GO
GRANT REFERENCES ON  [dbo].[cdacctcode] TO [public]
GO
GRANT SELECT ON  [dbo].[cdacctcode] TO [public]
GO
GRANT UPDATE ON  [dbo].[cdacctcode] TO [public]
GO
