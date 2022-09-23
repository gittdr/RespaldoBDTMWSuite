CREATE TABLE [dbo].[actg_temp_tempstoplist]
(
[sp_id] [int] NULL,
[ord_hdrnumber] [int] NULL,
[stp_number] [int] NULL,
[lgh_number] [int] NULL,
[evt_sequence] [int] NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[actg_temp_tempstoplist] TO [public]
GO
GRANT INSERT ON  [dbo].[actg_temp_tempstoplist] TO [public]
GO
GRANT REFERENCES ON  [dbo].[actg_temp_tempstoplist] TO [public]
GO
GRANT SELECT ON  [dbo].[actg_temp_tempstoplist] TO [public]
GO
GRANT UPDATE ON  [dbo].[actg_temp_tempstoplist] TO [public]
GO
