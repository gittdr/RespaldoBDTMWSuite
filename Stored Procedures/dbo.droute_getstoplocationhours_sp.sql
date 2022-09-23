SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
  
CREATE PROCEDURE  [dbo].[droute_getstoplocationhours_sp]  (@p_cmp_id varchar(8) )
AS
 /*
   
  
  REVISION
  8/18/11 DPETE PTS 58289 returns the hours of operation for a company in the form needed for a Direct Route request
       
  */


--declare @hours table (PatternField varchar(7), openField varchar(50), closeField varchar(50))

--insert into @hours
select dayofweek = 
 isnull((case WindowDay 
    when 'MON' then 'M'
    when 'TUE' then 'T'
    when 'WED' then 'W'
    when 'THU' then 'R'
    when  'FRI' then 'F'
    when 'SAT' then 'A'
    when 'SUN' then 'S'
    when 'MTWTF' then 'MTWRF'
    end),'SMTWRFA')
    ,sartdatetime = '1900-01-01T' + CONVERT(varchar(15),windowstart,108)
    ,enddatetime = '1900-01-01T' + CONVERT(varchar(15),windowend,108)
 from company_hourswindow
 where cmp_id = @p_cmp_id

GO
GRANT EXECUTE ON  [dbo].[droute_getstoplocationhours_sp] TO [public]
GO
