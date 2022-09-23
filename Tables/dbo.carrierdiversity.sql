CREATE TABLE [dbo].[carrierdiversity]
(
[cd_id] [int] NOT NULL IDENTITY(1, 1),
[car_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cd_ethnicity] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cd_gender] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cd_small_business] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cd_employee_count] [int] NULL,
[cd_other1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cd_other2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[carrierdiversity] ADD CONSTRAINT [pk_carrierdiversity_cd_id] PRIMARY KEY CLUSTERED ([cd_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_carrierdiversity_car_id] ON [dbo].[carrierdiversity] ([car_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[carrierdiversity] TO [public]
GO
GRANT INSERT ON  [dbo].[carrierdiversity] TO [public]
GO
GRANT REFERENCES ON  [dbo].[carrierdiversity] TO [public]
GO
GRANT SELECT ON  [dbo].[carrierdiversity] TO [public]
GO
GRANT UPDATE ON  [dbo].[carrierdiversity] TO [public]
GO
