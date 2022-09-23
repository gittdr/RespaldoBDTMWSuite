CREATE TABLE [dbo].[associate_pay_entry]
(
[entry_id] [int] NOT NULL,
[mov_number] [int] NOT NULL,
[processed_date] [datetime] NOT NULL,
[processed_by] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[transferred_date] [datetime] NULL,
[notes] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[entry_type] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[accounting_year] [smallint] NULL,
[accounting_period] [tinyint] NULL,
[accounting_week] [tinyint] NULL,
[ape_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ape_exportstatus] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[associate_pay_entry] ADD CONSTRAINT [associate_pay_entry_pk] PRIMARY KEY CLUSTERED ([entry_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[associate_pay_entry] TO [public]
GO
GRANT INSERT ON  [dbo].[associate_pay_entry] TO [public]
GO
GRANT SELECT ON  [dbo].[associate_pay_entry] TO [public]
GO
GRANT UPDATE ON  [dbo].[associate_pay_entry] TO [public]
GO
