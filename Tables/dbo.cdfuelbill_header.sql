CREATE TABLE [dbo].[cdfuelbill_header]
(
[cfb_xfacetype] [int] NOT NULL IDENTITY(100, 1),
[cfb_xfacename] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cfb_xfacedescription] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfb_systemcode] [int] NOT NULL CONSTRAINT [df_cdfuelbill_header_cfb_systemcode] DEFAULT (0),
[cfb_retired] [int] NOT NULL CONSTRAINT [df_cdfuelbill_header_cfb_retired] DEFAULT (0),
[cfb_currency] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_cdfuelbill_header_cfb_currency] DEFAULT ('US$'),
[cfb_accountid] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfb_customerid] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfb_shortname] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfb_payto] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_cdfuelbill_header_cfb_payto] DEFAULT ('UNKNOWN'),
[cfb_gp_payableaccount] [varchar] (66) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfb_bulk] [int] NOT NULL CONSTRAINT [df_cdfuelbill_header_cfb_bulk] DEFAULT (0),
[cfb_GMTDelta] [int] NULL,
[cfb_license_key] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfb_license_key2] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfb_preprocess] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_cdfuelbill_header_cfb_preprocess] DEFAULT ('N'),
[cfb_validate_otherfuel_code] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfb_vendor] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfb_cardstatusdef] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfb_DisableAutoCreateCard] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfb_process_other_fuel] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dw_timestamp] [timestamp] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cdfuelbill_header] ADD CONSTRAINT [pk_cdfuelbillheader] PRIMARY KEY CLUSTERED ([cfb_xfacetype]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [uk_fuelheader] ON [dbo].[cdfuelbill_header] ([cfb_xfacename]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_CDFuelbill_Header_timestamp] ON [dbo].[cdfuelbill_header] ([dw_timestamp]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[cdfuelbill_header] TO [public]
GO
GRANT INSERT ON  [dbo].[cdfuelbill_header] TO [public]
GO
GRANT REFERENCES ON  [dbo].[cdfuelbill_header] TO [public]
GO
GRANT SELECT ON  [dbo].[cdfuelbill_header] TO [public]
GO
GRANT UPDATE ON  [dbo].[cdfuelbill_header] TO [public]
GO
