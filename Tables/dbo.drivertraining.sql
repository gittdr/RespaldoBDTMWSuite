CREATE TABLE [dbo].[drivertraining]
(
[mpp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[drr_traindate] [datetime] NOT NULL,
[drr_hours] [decimal] (8, 2) NULL,
[drr_type] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[drr_instructor] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[drr_description] [varchar] (72) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[drr_code] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[timestamp] [timestamp] NULL,
[sn] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [pk_drt] ON [dbo].[drivertraining] ([mpp_id], [drr_traindate], [drr_code]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[drivertraining] TO [public]
GO
GRANT INSERT ON  [dbo].[drivertraining] TO [public]
GO
GRANT REFERENCES ON  [dbo].[drivertraining] TO [public]
GO
GRANT SELECT ON  [dbo].[drivertraining] TO [public]
GO
GRANT UPDATE ON  [dbo].[drivertraining] TO [public]
GO
