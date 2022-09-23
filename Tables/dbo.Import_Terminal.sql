CREATE TABLE [dbo].[Import_Terminal]
(
[cmp_id] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cmp_name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_address1] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_address2] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_city_name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_state] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_zip] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_country] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_phone] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_currency] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_nmstct] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[num_doors] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ownership_type] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[is_relay] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[is_breakbulk] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[is_pick_delv] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_num_prefix] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_num_length] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[preference] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[turnaround_hours] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[isloaded] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__Import_Te__isloa__5CD56218] DEFAULT ('N'),
[err_msg] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[Import_Terminal] TO [public]
GO
GRANT INSERT ON  [dbo].[Import_Terminal] TO [public]
GO
GRANT REFERENCES ON  [dbo].[Import_Terminal] TO [public]
GO
GRANT SELECT ON  [dbo].[Import_Terminal] TO [public]
GO
GRANT UPDATE ON  [dbo].[Import_Terminal] TO [public]
GO
