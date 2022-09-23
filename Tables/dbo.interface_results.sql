CREATE TABLE [dbo].[interface_results]
(
[record_id] [int] NOT NULL IDENTITY(1, 1),
[ltsl_order] [int] NULL,
[ps_order] [char] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[status_code] [int] NULL,
[status_message] [char] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[created_date] [datetime] NULL,
[batch_code] [int] NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[interface_results] TO [public]
GO
GRANT INSERT ON  [dbo].[interface_results] TO [public]
GO
GRANT REFERENCES ON  [dbo].[interface_results] TO [public]
GO
GRANT SELECT ON  [dbo].[interface_results] TO [public]
GO
GRANT UPDATE ON  [dbo].[interface_results] TO [public]
GO
