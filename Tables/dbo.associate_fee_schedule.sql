CREATE TABLE [dbo].[associate_fee_schedule]
(
[brn_id] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[fee_schedule_itemcode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[associate_percent] [decimal] (10, 4) NULL,
[description] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[active] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[manual] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[created_date] [datetime] NULL,
[created_by] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[modified_date] [datetime] NULL,
[modified_by] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[allow_rev_allocation_edits] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [df_allow_rev_alloc_edits] DEFAULT ('N')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[associate_fee_schedule] ADD CONSTRAINT [associate_fee_schedule_pk] PRIMARY KEY CLUSTERED ([brn_id], [fee_schedule_itemcode]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[associate_fee_schedule] TO [public]
GO
GRANT INSERT ON  [dbo].[associate_fee_schedule] TO [public]
GO
GRANT SELECT ON  [dbo].[associate_fee_schedule] TO [public]
GO
GRANT UPDATE ON  [dbo].[associate_fee_schedule] TO [public]
GO
