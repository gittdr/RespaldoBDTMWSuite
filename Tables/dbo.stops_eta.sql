CREATE TABLE [dbo].[stops_eta]
(
[stp_number] [int] NOT NULL,
[lgh_number] [int] NOT NULL,
[ste_seconds_out] [int] NOT NULL,
[ste_miles_out] [decimal] (6, 2) NOT NULL,
[ste_updated] [datetime] NOT NULL CONSTRAINT [DF__stops_eta__ste_u__48FE4BF7] DEFAULT (getdate()),
[ckc_number] [int] NOT NULL,
[ste_original_earliest] [datetime] NULL,
[ste_original_arrival] [datetime] NULL,
[ste_original_departure] [datetime] NULL,
[ste_updated_earliest] [datetime] NULL,
[ste_updated_arrival] [datetime] NULL,
[ste_updated_departure] [datetime] NULL,
[ste_message_count] [tinyint] NULL,
[ste_original_latest] [datetime] NULL,
[ste_updated_latest] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[stops_eta] ADD CONSTRAINT [pk_stops_eta] PRIMARY KEY CLUSTERED ([stp_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [stops_eta_ckc_number] ON [dbo].[stops_eta] ([ckc_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [stops_eta_lgh_number] ON [dbo].[stops_eta] ([lgh_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[stops_eta] TO [public]
GO
GRANT INSERT ON  [dbo].[stops_eta] TO [public]
GO
GRANT REFERENCES ON  [dbo].[stops_eta] TO [public]
GO
GRANT SELECT ON  [dbo].[stops_eta] TO [public]
GO
GRANT UPDATE ON  [dbo].[stops_eta] TO [public]
GO
