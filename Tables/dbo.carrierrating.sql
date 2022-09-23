CREATE TABLE [dbo].[carrierrating]
(
[cra_id] [int] NOT NULL IDENTITY(1, 1),
[car_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[lgh_number] [int] NOT NULL,
[cra_rating] [tinyint] NULL,
[cra_reason] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cra_note] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cra_user] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cra_lastupdated] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[carrierrating] ADD CONSTRAINT [PK_carrierrating] PRIMARY KEY CLUSTERED ([cra_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[carrierrating] TO [public]
GO
GRANT INSERT ON  [dbo].[carrierrating] TO [public]
GO
GRANT REFERENCES ON  [dbo].[carrierrating] TO [public]
GO
GRANT SELECT ON  [dbo].[carrierrating] TO [public]
GO
GRANT UPDATE ON  [dbo].[carrierrating] TO [public]
GO
