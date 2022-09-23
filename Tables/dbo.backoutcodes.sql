CREATE TABLE [dbo].[backoutcodes]
(
[boc_number] [int] NOT NULL IDENTITY(1, 1),
[boc_itemcode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[boc_description] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[timestamp] [binary] (8) NULL,
[boc_systemcode] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__backoutco__boc_s__20AD9DE2] DEFAULT ('N'),
[boc_retired] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__backoutco__boc_r__21A1C21B] DEFAULT ('N'),
[boc_quantity] [float] NULL,
[boc_rate] [float] NULL,
[boc_unit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[boc_maxreduction] [float] NULL,
[boc_postbackout] [int] NULL,
[boc_paytype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[backoutcodes] ADD CONSTRAINT [AutoPK_backoutcodes] PRIMARY KEY CLUSTERED ([boc_itemcode]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[backoutcodes] TO [public]
GO
GRANT INSERT ON  [dbo].[backoutcodes] TO [public]
GO
GRANT REFERENCES ON  [dbo].[backoutcodes] TO [public]
GO
GRANT SELECT ON  [dbo].[backoutcodes] TO [public]
GO
GRANT UPDATE ON  [dbo].[backoutcodes] TO [public]
GO
