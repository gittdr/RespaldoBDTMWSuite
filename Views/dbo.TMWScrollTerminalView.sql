SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[TMWScrollTerminalView]
AS
SELECT * FROM dbo.Company
WHERE cmp_terminal = 'Y'
GO
GRANT DELETE ON  [dbo].[TMWScrollTerminalView] TO [public]
GO
GRANT INSERT ON  [dbo].[TMWScrollTerminalView] TO [public]
GO
GRANT REFERENCES ON  [dbo].[TMWScrollTerminalView] TO [public]
GO
GRANT SELECT ON  [dbo].[TMWScrollTerminalView] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMWScrollTerminalView] TO [public]
GO
