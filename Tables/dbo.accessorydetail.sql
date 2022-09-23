CREATE TABLE [dbo].[accessorydetail]
(
[stp_number] [int] NOT NULL,
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[acc_id] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[acd_date] [datetime] NOT NULL,
[acd_in] [int] NOT NULL,
[acd_out] [int] NOT NULL,
[acd_cost] [money] NULL,
[acd_total] [money] NULL,
[acd_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_number] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[acd_processed] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[acd_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[timestamp] [timestamp] NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[accessorydetail] TO [public]
GO
GRANT INSERT ON  [dbo].[accessorydetail] TO [public]
GO
GRANT REFERENCES ON  [dbo].[accessorydetail] TO [public]
GO
GRANT SELECT ON  [dbo].[accessorydetail] TO [public]
GO
GRANT UPDATE ON  [dbo].[accessorydetail] TO [public]
GO
