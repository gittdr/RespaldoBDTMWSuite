CREATE TABLE [dbo].[actg_temp_excludedlegs]
(
[sp_id] [int] NULL,
[lgh_number] [int] NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[actg_temp_excludedlegs] TO [public]
GO
GRANT INSERT ON  [dbo].[actg_temp_excludedlegs] TO [public]
GO
GRANT REFERENCES ON  [dbo].[actg_temp_excludedlegs] TO [public]
GO
GRANT SELECT ON  [dbo].[actg_temp_excludedlegs] TO [public]
GO
GRANT UPDATE ON  [dbo].[actg_temp_excludedlegs] TO [public]
GO
