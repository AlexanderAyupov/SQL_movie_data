/*
Find the titles of all movies directed by Steven Spielberg.
*/
Select title
From Movie
Where director = 'Steven Spielberg'

/*
Find all years that have a movie that received a rating of 4 or 5, and sort them in increasing order.
*/
Select distinct year
From Movie, Rating
Where Movie.mID = Rating.mID and stars BETWEEN 4 and 5
Order by year

/*
Find the titles of all movies that have no ratings.
*/
Select title
From Movie Left Outer Join Rating
ON Movie.mID = Rating.mID
Where stars is NULL

/*
Some reviewers didn't provide a date with their rating. Find the names of all reviewers who have ratings with a NULL value for the date.
*/
Select name
From Reviewer, Rating
Where Reviewer.rID = Rating.rID
AND ratingDate is NULL

/*
Write a query to return the ratings data in a more readable format: reviewer name, movie title, stars, and ratingDate. 
Also, sort the data, first by reviewer name, then by movie title, and lastly by number of stars.
*/
Select name, title, stars, ratingDate
From Reviewer, Rating, Movie
Where Reviewer.rID = Rating.rID AND Rating.mID = Movie.mID
Order by name, title, stars

/*
For all cases where the same reviewer rated the same movie twice and gave it a higher rating the second time, 
return the reviewer's name and the title of the movie.
*/
Select Reviewer.name, Movie.title
From (Select R1.rID, R1.mID
From Rating R1, Rating R2
Where (R1.rID=R2.rID) AND (R1.mID=R2.miD) AND (R1.ratingDate < R2.ratingDate) AND (R1.stars < R2.stars)) AS C
LEFT JOIN Reviewer ON C.rID = Reviewer.rID
LEFT JOIN Movie ON C.mID = Movie.mID

/*
For each movie that has at least one rating, find the highest number of stars that movie received. 
Return the movie title and number of stars. Sort by movie title.
*/
Select Movie.title, MAX(stars) AS MaxRating
From Rating
Left outer Join Movie
ON Movie.mID = Rating.mID
Group by Movie.title

/*
For each movie, return the title and the 'rating spread', that is, the difference between highest and lowest ratings given to that movie. 
Sort by rating spread from highest to lowest, then by movie title.
*/
Select Movie.title, (MAX(stars)-Min(stars)) AS RatingSpread 
From Rating
Left outer Join Movie
ON Movie.mID = Rating.mID
Group by Movie.title
Order by RatingSpread desc, Movie.title

/*
Find the difference between the average rating of movies released before 1980 and the average rating of movies released after 1980. 
(Make sure to calculate the average rating for each movie, then the average of those averages for movies before 1980 and movies after. 
Don't just calculate the overall average rating before and after 1980.)
*/

select avg(early.avgStar)-avg(late.avgStar)
from (select avg(stars) as avgStar
      from Movie join Rating ON Movie.mID=Rating.mID
	  where year < 1980
      group by Movie.mID) as early,
      (select avg(stars) as avgStar
      from Movie join Rating ON Movie.mID=Rating.mID
      where year > 1980
	  group by Movie.mID) as late

/*
Find the names of all reviewers who rated Gone with the Wind.
*/
Select Distinct name
From Movie, Rating, Reviewer
Where Movie.mID=Rating.mID AND Rating.rID=Reviewer.rID
AND title='Gone with the Wind'

/*
For any rating where the reviewer is the same as the director of the movie, return the reviewer name, movie title, and number of stars.
*/
Select name, title, stars
From Movie, Rating, Reviewer
Where Movie.mID=Rating.mID AND Rating.rID=Reviewer.rID
AND director = name

/*
Return all reviewer names and movie names together in a single list, alphabetized. 
(Sorting by the first name of the reviewer and first word in the title is fine; no need for special processing on last names or removing "The".)
*/
Select name as cname
from Reviewer
union
Select title
from Movie as cname
order by cname desc

/*
Find the titles of all movies not reviewed by Chris Jackson.
*/
Select title
From Movie
Where mID not in 
(Select mID From Rating, Reviewer Where Rating.rID=Reviewer.rID AND name = 'Chris Jackson')

select title
from Movie
where mID not in (select mID
from Rating
where rID in (select rID
from Reviewer
where name = 'Chris Jackson'))

/*
For all pairs of reviewers such that both reviewers gave a rating to the same movie, return the names of both reviewers. 
Eliminate duplicates, don't pair reviewers with themselves, and include each pair only once. 
For each pair, return the names in the pair in alphabetical order.
*/
SELECT DISTINCT Rev1.name, Rev2.name
FROM Rating R1, Rating R2, Reviewer Rev1, Reviewer Rev2
WHERE R1.mID = R2.mID AND R1.rID = Rev1.rID AND R2.rID = Rev2.rID AND Rev1.name < Rev2.name
ORDER BY Rev1.name, Rev2.name;

/*
For each rating that is the lowest (fewest stars) currently in the database, return the reviewer name, movie title, and number of stars.
*/
Select name, title, stars
From Movie, Rating, Reviewer
Where Movie.mID=Rating.mID AND Rating.rID=Reviewer.rID
AND stars = (SELECT MIN(Rating.stars) From Rating)

/*
List movie titles and average ratings, from highest-rated to lowest-rated. 
If two or more movies have the same average rating, list them in alphabetical order.
*/
Select title, AVG(stars)
From Movie, Rating
Where Movie.mID = Rating.mID
Group by title
Order by AVG(stars) desc, title

/*
Find the names of all reviewers who have contributed three or more ratings. 
(As an extra challenge, try writing the query without HAVING or without COUNT.)
*/

Select name
From Reviewer, Rating
Where Rating.rID=Reviewer.rID
Group by name
Having count(stars) >=3

SELECT name
FROM Reviewer
WHERE (SELECT COUNT(*) FROM Rating WHERE Rating.rId = Reviewer.rId) >= 3;

/*
Some directors directed more than one movie. For all such directors, return the titles of all movies directed by them, along with the director name. 
Sort by director name, then movie title. (As an extra challenge, try writing the query both with and without COUNT.)
*/

SELECT Movie.title, Movie.director
FROM 
(SELECT Movie.director
FROM Movie
GROUP BY Movie.director
Having COUNT(Movie.director)>1  
) AS M1
INNER JOIN Movie
ON Movie.director = M1.director
ORDER BY Movie.director, Movie.title

SELECT title, director
FROM Movie M1
WHERE (SELECT COUNT(*) FROM Movie M2 WHERE M1.director = M2.director) > 1
ORDER BY director, title;

/*
Find the movie(s) with the highest average rating. Return the movie title(s) and average rating. 
(Hint: This query is more difficult to write in SQLite than other systems; 
you might think of it as finding the highest average rating and then choosing the movie(s) with that average rating.)
*/

SELECT title, AVG(stars) as average
FROM MOVIE
INNER JOIN RATING ON Movie.mID = Rating.mID
INNER JOIN REVIEWER ON Reviewer.rID = Rating.rID
GROUP BY movie.mID, title
HAVING  AVG(stars) = (
SELECT MAX(avg_stars)
FROM (
SELECT title, AVG(stars) AS avg_stars
FROM MOVIE
INNER JOIN RATING ON Rating.mID = Movie.mID
GROUP BY movie.mID, title
) I
);

/*
Find the movie(s) with the lowest average rating. Return the movie title(s) and average rating. 
(Hint: This query may be more difficult to write in SQLite than other systems; 
you might think of it as finding the lowest average rating and then choosing the movie(s) with that average rating.)
*/
SELECT title, AVG(stars) as average
FROM MOVIE
INNER JOIN RATING ON Movie.mID = Rating.mID
INNER JOIN REVIEWER ON Reviewer.rID = Rating.rID
GROUP BY movie.mID, title
HAVING  AVG(stars) = (
SELECT MIN(avg_stars)
FROM (
SELECT title, AVG(stars) AS avg_stars
FROM MOVIE
INNER JOIN RATING ON Rating.mID = Movie.mID
GROUP BY movie.mID, title
) I
);
/*
For each director, return the director's name together with the title(s) of the movie(s) they directed that received the highest rating 
among all of their movies, and the value of that rating. Ignore movies whose director is NULL.
*/
select Distinct director, title, MAX(stars)
from movie m, rating r
where m.mid = r.mid and director is not null
group by director, title

/*
Add the reviewer Roger Ebert to your database, with an rID of 209.
*/
Insert into Reviewer values(209,'Robert Ebert')

/*
For all movies that have an average rating of 4 stars or higher, add 25 to the release year. (Update the existing tuples; don't insert new tuples.)
*/
update movie
set year = year+25
where mid in (select mid 
              from rating 
              group by mid 
              having avg(stars) >=4)

/*
Remove all ratings where the movie's year is before 1970 or after 2000, and the rating is fewer than 4 stars.
*/
Select*
From Movie

Delete from Rating
Where mID IN (Select mID From Movie Where year < 1970 or year > 2000)
AND stars < 4