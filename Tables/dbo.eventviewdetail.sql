CREATE TABLE [dbo].[eventviewdetail]
(
[evd_number] [int] NOT NULL IDENTITY(1, 1),
[evh_number] [int] NULL,
[evd_seq] [int] NULL,
[evd_eventcode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[evd_est_red] [int] NULL,
[evd_est_green] [int] NULL,
[evd_est_blue] [int] NULL,
[evd_act_red] [int] NULL,
[evd_act_green] [int] NULL,
[evd_act_blue] [int] NULL,
[evd_deftime] [int] NULL,
[evd_defevent] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[eventviewdetail] TO [public]
GO
GRANT INSERT ON  [dbo].[eventviewdetail] TO [public]
GO
GRANT SELECT ON  [dbo].[eventviewdetail] TO [public]
GO
GRANT UPDATE ON  [dbo].[eventviewdetail] TO [public]
GO
