CREATE TABLE [dbo].[nlmvehicletracking]
(
[nlm_trackingid] [int] NOT NULL IDENTITY(1, 1),
[ckc_number] [int] NULL,
[process_time] [datetime] NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[nlmvehicletracking] TO [public]
GO
GRANT INSERT ON  [dbo].[nlmvehicletracking] TO [public]
GO
GRANT REFERENCES ON  [dbo].[nlmvehicletracking] TO [public]
GO
GRANT SELECT ON  [dbo].[nlmvehicletracking] TO [public]
GO
GRANT UPDATE ON  [dbo].[nlmvehicletracking] TO [public]
GO
