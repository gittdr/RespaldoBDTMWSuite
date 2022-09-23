SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[fueltax_export_trc]

AS

SELECT  CONVERT(char(10),trc_number) trc_number,
	ISNULL(CONVERT(char(10),trc_owner), '          ') trc_owner,
	ISNULL(CONVERT(char(10),trc_company), '          ') trc_company,
	ISNULL(CONVERT(char(10),trc_division), '          ') trc_division,
	ISNULL(CONVERT(char(10),trc_terminal), '          ') trc_terminal,
	ISNULL(CONVERT(char(4),trc_year), '    ') trc_year,
	ISNULL(CONVERT(char(12),trc_make), '            ') trc_make,
	ISNULL(CONVERT(char(8),trc_licnum), '        ') trc_licnum,	
	ISNULL(CONVERT(char(2),trc_licstate), '  ') trc_licstate,
	ISNULL(CONVERT(char(6),trc_grosswgt), '      ') trc_grosswgt,
	ISNULL(CONVERT(char(2),trc_axles), '  ')trc_axles,
	ISNULL(CONVERT(char(10),trc_fleet), '          ') trc_fleet,
	CONVERT(char(1), '') fueltype,
	CONVERT(char(1),'') citytruckflag,
	ISNULL(CONVERT(char(10),trc_driver), '          ') trc_driver,
	CONVERT(char(3),trc_status) trc_status,
	ISNULL(CONVERT(char(8),trc_retiredate,112), '        ') trc_retiredate
INTO #t1
FROM tractorprofile

UPDATE #t1
SET trc_status = 'Y'
WHERE trc_status = 'OUT'

UPDATE #t1
SET trc_status = 'N',
    trc_retiredate = ''	
WHERE trc_status <> 'Y'

SELECT  CONVERT(char(10),trc_number) trc_number,
	ISNULL(CONVERT(char(10),trc_owner), '          ') trc_owner,
	ISNULL(CONVERT(char(10),trc_company), '          ') trc_company,
	ISNULL(CONVERT(char(10),trc_division), '          ') trc_division,
	ISNULL(CONVERT(char(10),trc_terminal), '          ') trc_terminal,
	ISNULL(CONVERT(char(4),trc_year), '    ') trc_year,
	ISNULL(CONVERT(char(12),trc_make), '            ') trc_make,
	ISNULL(CONVERT(char(8),trc_licnum), '        ') trc_licnum,	
	ISNULL(CONVERT(char(2),trc_licstate), '  ') trc_licstate,
	ISNULL(CONVERT(char(6),trc_grosswgt), '      ') trc_grosswgt,
	ISNULL(CONVERT(char(2),trc_axles), '  ')trc_axles,
	ISNULL(CONVERT(char(10),trc_fleet), '          ') trc_fleet,
	CONVERT(char(1), '') fueltype,
	CONVERT(char(1),'') citytruckflag,
	ISNULL(CONVERT(char(10),trc_driver), '          ') trc_driver,
	CONVERT(char(1),trc_status) trc_status,
	ISNULL(CONVERT(char(8),trc_retiredate), '        ') trc_retiredate
FROM #t1
ORDER BY trc_number

GO
GRANT EXECUTE ON  [dbo].[fueltax_export_trc] TO [public]
GO
