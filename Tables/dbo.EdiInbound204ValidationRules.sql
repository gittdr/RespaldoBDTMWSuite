CREATE TABLE [dbo].[EdiInbound204ValidationRules]
(
[evr_ident] [int] NOT NULL IDENTITY(1, 1),
[evr_billto] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[evr_trading_partner] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[evf_key] [varchar] (203) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[evr_evaluate] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[evr_overwrite] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[evr_display_name] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[evr_difference] [int] NOT NULL,
[evr_min] [int] NOT NULL,
[evr_max] [int] NOT NULL,
[evr_referencefield] [varchar] (203) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[evr_referencevalue] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[evr_parentsection] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[evr_createdby] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[evr_createdate] [datetime] NULL,
[evr_updatedby] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[evr_updatedate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EdiInbound204ValidationRules] ADD CONSTRAINT [PK_EdiInbound204ValidationRules] PRIMARY KEY CLUSTERED ([evr_ident]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[EdiInbound204ValidationRules] TO [public]
GO
GRANT INSERT ON  [dbo].[EdiInbound204ValidationRules] TO [public]
GO
GRANT REFERENCES ON  [dbo].[EdiInbound204ValidationRules] TO [public]
GO
GRANT SELECT ON  [dbo].[EdiInbound204ValidationRules] TO [public]
GO
GRANT UPDATE ON  [dbo].[EdiInbound204ValidationRules] TO [public]
GO
