CREATE TABLE [dbo].[payratekey]
(
[timestamp] [timestamp] NULL,
[prk_number] [int] NOT NULL,
[asgn_type] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[asgn_id] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prk_paybasis] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[prh_number] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[prh_name] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prk_name] [varchar] (21) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmd_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_type1] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_type2] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_type3] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_type4] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prk_team] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prk_effective] [datetime] NULL,
[prk_deliver] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prk_car_trc_flag] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__payrateke__prk_c__729BEF18] DEFAULT ('BTH')
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [k_asgn_id] ON [dbo].[payratekey] ([asgn_id]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[payratekey] TO [public]
GO
GRANT INSERT ON  [dbo].[payratekey] TO [public]
GO
GRANT REFERENCES ON  [dbo].[payratekey] TO [public]
GO
GRANT SELECT ON  [dbo].[payratekey] TO [public]
GO
GRANT UPDATE ON  [dbo].[payratekey] TO [public]
GO
