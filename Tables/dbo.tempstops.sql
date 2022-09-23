CREATE TABLE [dbo].[tempstops]
(
[toh_ordernumber] [int] NOT NULL,
[ts_seq] [tinyint] NOT NULL,
[ts_location] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ts_type] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ts_arrival] [datetime] NOT NULL,
[ts_earliest] [datetime] NULL,
[ts_latest] [datetime] NULL,
[ts_departure] [datetime] NULL,
[ts_reftype] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ts_refnum] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ts_description] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ts_weight] [float] NULL,
[ts_count] [int] NULL,
[ts_miles] [int] NULL,
[ts_contact] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ts_event] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ts_dispatch_seq] [tinyint] NULL,
[ts_driver1] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ts_driver2] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ts_trc_num] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ts_trl_num] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ts_city] [int] NULL,
[mov_number] [int] NULL,
[ts_trl_num2] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tempstops] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ts_specialhandling] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ts_weightunit] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[toh_tstampq] [int] NULL,
[ts_carrier] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tempstops_ident] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tempstops] WITH NOCHECK ADD CONSTRAINT [CK_ts_type] CHECK (([ts_type]='NONE' OR [ts_type]='DRP' OR [ts_type]='PUP'))
GO
ALTER TABLE [dbo].[tempstops] ADD CONSTRAINT [prkey_tempstops] PRIMARY KEY CLUSTERED ([tempstops_ident]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [pk_key] ON [dbo].[tempstops] ([toh_tstampq], [toh_ordernumber], [ts_seq]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tempstops] ADD CONSTRAINT [FK_city_code] FOREIGN KEY ([ts_city]) REFERENCES [dbo].[city] ([cty_code])
GO
ALTER TABLE [dbo].[tempstops] ADD CONSTRAINT [FK_ts_driver1] FOREIGN KEY ([ts_driver1]) REFERENCES [dbo].[manpowerprofile] ([mpp_id])
GO
ALTER TABLE [dbo].[tempstops] ADD CONSTRAINT [FK_ts_driver2] FOREIGN KEY ([ts_driver2]) REFERENCES [dbo].[manpowerprofile] ([mpp_id])
GO
ALTER TABLE [dbo].[tempstops] ADD CONSTRAINT [FK_ts_event] FOREIGN KEY ([ts_event]) REFERENCES [dbo].[eventcodetable] ([abbr])
GO
ALTER TABLE [dbo].[tempstops] ADD CONSTRAINT [FK_ts_location] FOREIGN KEY ([ts_location]) REFERENCES [dbo].[company] ([cmp_id])
GO
ALTER TABLE [dbo].[tempstops] WITH NOCHECK ADD CONSTRAINT [FK_ts_trc_num] FOREIGN KEY ([ts_trc_num]) REFERENCES [dbo].[tractorprofile] ([trc_number])
GO
GRANT DELETE ON  [dbo].[tempstops] TO [public]
GO
GRANT INSERT ON  [dbo].[tempstops] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tempstops] TO [public]
GO
GRANT SELECT ON  [dbo].[tempstops] TO [public]
GO
GRANT UPDATE ON  [dbo].[tempstops] TO [public]
GO
