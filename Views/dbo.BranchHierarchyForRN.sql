SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create VIEW [dbo].[BranchHierarchyForRN]

AS

-- get top level ONLY
select t1.brn_parent as brn_parent_1
,t1.brn_id as brn_id_1
,t1.brn_name as brn_name_1
,NULL as brn_parent_2
,NULL as brn_id_2
,NULL as brn_name_2
,NULL as brn_parent_3
,NULL as brn_id_3
,NULL as brn_name_3
,NULL as brn_parent_4
,NULL as brn_id_4
,NULL as brn_name_4
,NULL as brn_parent_5
,NULL as brn_id_5
,NULL as brn_name_5
from (select brn_id, brn_name, brn_parent from branch where brn_parent = 'UNKNOWN' ) t1 --AND brn_id <> 'UNKNOWN'

UNION 
-- get top 2 levels ONLY
select t1.brn_parent as brn_parent_1
,t1.brn_id as brn_id_1
,t1.brn_name as brn_name_1
,t2.brn_parent as brn_parent_2
,t2.brn_id as brn_id_2
,t2.brn_name as brn_name_2
,NULL as brn_parent_3
,NULL as brn_id_3
,NULL as brn_name_3
,NULL as brn_parent_4
,NULL as brn_id_4
,NULL as brn_name_4
,NULL as brn_parent_5
,NULL as brn_id_5
,NULL as brn_name_5
from (select brn_id, brn_name, brn_parent from branch where brn_parent = 'UNKNOWN' AND brn_id <> 'UNKNOWN') as t1
INNER JOIN
(Select 2 as Level, brn_parent,brn_id,brn_name from branch where brn_parent in 
        (select brn_id from branch B2 where B2.brn_parent = 'UNKNOWN' AND B2.brn_id <> 'UNKNOWN')) as t2 ON t1.brn_id = t2.brn_parent

UNION 
-- get top 3 levels ONLY
select t1.brn_parent as brn_parent_1
,t1.brn_id as brn_id_1
,t1.brn_name as brn_name_1
,t2.brn_parent as brn_parent_2
,t2.brn_id as brn_id_2
,t2.brn_name as brn_name_2
,t3.brn_parent as brn_parent_3
,t3.brn_id as brn_id_3
,t3.brn_name as brn_name_3
,NULL as brn_parent_4
,NULL as brn_id_4
,NULL as brn_name_4
,NULL as brn_parent_5
,NULL as brn_id_5
,NULL as brn_name_5
from (select brn_id, brn_name, brn_parent from branch where brn_parent = 'UNKNOWN' AND brn_id <> 'UNKNOWN') as t1
INNER JOIN
(Select 2 as Level, brn_parent,brn_id,brn_name from branch where brn_parent in 
        (select brn_id from branch B2 where B2.brn_parent = 'UNKNOWN' AND B2.brn_id <> 'UNKNOWN')) as t2 ON t1.brn_id = t2.brn_parent
INNER JOIN
(Select 3 as Level, brn_parent, brn_id,brn_name from branch where brn_parent in 
        (Select brn_id from branch B3 where B3.brn_parent in 
                        (select brn_id from branch B2 where B2.brn_parent = 'UNKNOWN' AND B2.brn_id <> 'UNKNOWN'))) t3 ON t2.brn_id = t3.brn_parent


UNION 
-- get top 4 levels ONLY
select t1.brn_parent as brn_parent_1
,t1.brn_id as brn_id_1
,t1.brn_name as brn_name_1
,t2.brn_parent as brn_parent_2
,t2.brn_id as brn_id_2
,t2.brn_name as brn_name_2
,t3.brn_parent as brn_parent_3
,t3.brn_id as brn_id_3
,t3.brn_name as brn_name_3
,t4.brn_parent as brn_parent_4
,t4.brn_id as brn_id_4
,t4.brn_name as brn_name_4
,NULL as brn_parent_5
,NULL as brn_id_5
,NULL as brn_name_5
from (select brn_id, brn_name, brn_parent from branch where brn_parent = 'UNKNOWN' AND brn_id <> 'UNKNOWN') as t1
INNER JOIN
(Select 2 as Level, brn_parent,brn_id,brn_name from branch where brn_parent in 
        (select brn_id from branch B2 where B2.brn_parent = 'UNKNOWN' AND B2.brn_id <> 'UNKNOWN')) as t2 ON t1.brn_id = t2.brn_parent
INNER JOIN
(Select 3 as Level, brn_parent, brn_id,brn_name from branch where brn_parent in 
        (Select brn_id from branch B3 where B3.brn_parent in 
                        (select brn_id from branch B2 where B2.brn_parent = 'UNKNOWN' AND B2.brn_id <> 'UNKNOWN'))) t3 ON t2.brn_id = t3.brn_parent
INNER JOIN
(Select 4 as Level, brn_parent,brn_id,brn_name from branch where brn_parent in 
        (Select brn_id from branch B1 where B1.brn_parent in 
                        (Select B3.brn_id from branch B3 where B3.brn_parent in 
                                        (select B2.brn_id from branch B2 where B2.brn_parent = 'UNKNOWN' AND B2.brn_id <> 'UNKNOWN')))) t4 ON t3.brn_id = t4.brn_parent




GO
GRANT SELECT ON  [dbo].[BranchHierarchyForRN] TO [public]
GO
