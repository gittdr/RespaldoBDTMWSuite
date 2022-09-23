CREATE TABLE [dbo].[edi_report_stops_temp]
(
[stp] [int] NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[edi_report_stops_temp] TO [public]
GO
GRANT INSERT ON  [dbo].[edi_report_stops_temp] TO [public]
GO
GRANT REFERENCES ON  [dbo].[edi_report_stops_temp] TO [public]
GO
GRANT SELECT ON  [dbo].[edi_report_stops_temp] TO [public]
GO
GRANT UPDATE ON  [dbo].[edi_report_stops_temp] TO [public]
GO
