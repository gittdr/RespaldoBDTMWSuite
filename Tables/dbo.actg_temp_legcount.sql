CREATE TABLE [dbo].[actg_temp_legcount]
(
[sp_id] [int] NULL,
[lgh_number] [int] NULL,
[occurrences] [int] NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[actg_temp_legcount] TO [public]
GO
GRANT INSERT ON  [dbo].[actg_temp_legcount] TO [public]
GO
GRANT REFERENCES ON  [dbo].[actg_temp_legcount] TO [public]
GO
GRANT SELECT ON  [dbo].[actg_temp_legcount] TO [public]
GO
GRANT UPDATE ON  [dbo].[actg_temp_legcount] TO [public]
GO
