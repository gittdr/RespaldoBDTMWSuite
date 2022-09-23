CREATE TABLE [dbo].[commodityclass]
(
[ccl_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ccl_description] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[alk_hazlevel] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rand_hazlevel] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[other_hazlevel] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ccl_isretired] [bit] NOT NULL CONSTRAINT [DF__commodity__ccl_i__3360E337] DEFAULT ((0)),
[default_uom] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ccl_displayorder] [int] NULL,
[ccl_exclusive] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__commodity__ccl_e__55992D06] DEFAULT ('N'),
[ccl_volumefromloads] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[commodityclass] TO [public]
GO
GRANT INSERT ON  [dbo].[commodityclass] TO [public]
GO
GRANT REFERENCES ON  [dbo].[commodityclass] TO [public]
GO
GRANT SELECT ON  [dbo].[commodityclass] TO [public]
GO
GRANT UPDATE ON  [dbo].[commodityclass] TO [public]
GO
