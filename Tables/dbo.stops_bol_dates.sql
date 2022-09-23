CREATE TABLE [dbo].[stops_bol_dates]
(
[stp_number] [int] NOT NULL,
[bol_arrivaldate] [datetime] NOT NULL,
[bol_departuredate] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[stops_bol_dates] ADD CONSTRAINT [PK__stops_bol_dates__63E74C5D] PRIMARY KEY CLUSTERED ([stp_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[stops_bol_dates] TO [public]
GO
GRANT INSERT ON  [dbo].[stops_bol_dates] TO [public]
GO
GRANT REFERENCES ON  [dbo].[stops_bol_dates] TO [public]
GO
GRANT SELECT ON  [dbo].[stops_bol_dates] TO [public]
GO
GRANT UPDATE ON  [dbo].[stops_bol_dates] TO [public]
GO
