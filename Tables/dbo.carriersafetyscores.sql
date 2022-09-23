CREATE TABLE [dbo].[carriersafetyscores]
(
[css_id] [int] NOT NULL IDENTITY(1, 1),
[car_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[css_score_category] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[css_score] [decimal] (8, 2) NULL,
[css_scoredt] [datetime] NULL,
[css_serious_violation] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[css_basic_alert] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[carriersafetyscores] ADD CONSTRAINT [pk_carriersafetyscores_css_id] PRIMARY KEY CLUSTERED ([css_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_carriersafetyscores_car_id] ON [dbo].[carriersafetyscores] ([car_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[carriersafetyscores] TO [public]
GO
GRANT INSERT ON  [dbo].[carriersafetyscores] TO [public]
GO
GRANT REFERENCES ON  [dbo].[carriersafetyscores] TO [public]
GO
GRANT SELECT ON  [dbo].[carriersafetyscores] TO [public]
GO
GRANT UPDATE ON  [dbo].[carriersafetyscores] TO [public]
GO
