CREATE TABLE [dbo].[StateFuelTax]
(
[sft_id] [int] NOT NULL IDENTITY(1, 1),
[sftState] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[sftDate] [datetime] NOT NULL,
[sftRate] [money] NOT NULL,
[sftcreatedby] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sftcreatedate] [datetime] NULL,
[sftupdatedby] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sftupdatedate] [datetime] NULL,
[sftrateoverabove] [money] NULL CONSTRAINT [DF__StateFuel__sftra__613FE9DC] DEFAULT ((0)),
[sftratepermile] [money] NULL CONSTRAINT [DF__StateFuel__sftra__62340E15] DEFAULT ((0)),
[sftExcludeTollMiles] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__StateFuel__sftEx__6328324E] DEFAULT ('N'),
[country_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sftend_date] [datetime] NULL,
[gross_min_wgt] [float] NULL,
[gross_max_wgt] [float] NULL,
[fuel_type] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fleet] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fuel_mileage_tax_type] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[it_statefueltax] on [dbo].[StateFuelTax] for insert as 
SET NOCOUNT ON

declare @tmwuser varchar(255)
exec gettmwuser @tmwuser output

update statefueltax
   set sftcreatedby = @tmwuser,
       sftcreatedate = getdate()
  from inserted 
 where statefueltax.sft_id = inserted.sft_id

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[ut_statefueltax] on [dbo].[StateFuelTax] for update as 
SET NOCOUNT ON

declare @tmwuser varchar(255)
exec gettmwuser @tmwuser output

update statefueltax
   set sftupdatedby = @tmwuser,
       sftupdatedate = getdate()
  from inserted 
 where statefueltax.sft_id = inserted.sft_id

GO
GRANT DELETE ON  [dbo].[StateFuelTax] TO [public]
GO
GRANT INSERT ON  [dbo].[StateFuelTax] TO [public]
GO
GRANT SELECT ON  [dbo].[StateFuelTax] TO [public]
GO
GRANT UPDATE ON  [dbo].[StateFuelTax] TO [public]
GO
