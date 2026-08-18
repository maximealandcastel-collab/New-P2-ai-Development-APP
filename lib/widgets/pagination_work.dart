/*




bool isReelsCommentLoading = false;
bool isCommentPaginating = false;
int commentPage = 1;
int commentLimit = 20;
int? commentTotalPages;
bool _hasMoreComments = true;

ShowCommentModel? commentModel;
List<Results> commentsList = [];

Future<bool> getReelsComment(
    String reelsId, {
      bool isPaginated = false,
      bool refresh = false,
    }) async {
  // Reset for refresh
  if (refresh) {
    _resetCommentPagination();
    isPaginated = false;
  }

  if (!_hasMoreComments && isPaginated) {
    debugPrint('No more comments to load');
    return false;
  }

  if ((isReelsCommentLoading && !isPaginated) || (isCommentPaginating && isPaginated)) {
    return false;
  }

  if (isPaginated) {
    isCommentPaginating = true;
  } else {
    isReelsCommentLoading = true;
    if (!refresh) {
      commentsList.clear();
    }
  }
  update();

  bool isSuccess = false;
  try {
    final response = await ApiClient.getData(
      ApiUrls.getReelsCommentUrl(reelsId, page: commentPage, limit: commentLimit),
    );
    final responseData = response.body;

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = responseData['data'];
      commentModel = ShowCommentModel.fromJson(data);

      final newComments = commentModel?.results ?? [];

      if (isPaginated) {
        commentsList.addAll(newComments);
      } else {
        commentsList = newComments;
      }

      commentTotalPages = commentModel?.totalPages;

      // Update pagination logic
      _hasMoreComments = commentPage < (commentTotalPages ?? 1);
      if (_hasMoreComments) {
        commentPage++;
      }

      _message = responseData['message'];
      debugPrint('✅ Comments loaded - Page: $commentPage, HasMore: $_hasMoreComments, Items: ${newComments.length}');
      isSuccess = true;
    } else {
      _message = responseData['message'];
      debugPrint('❌ Comments failed: $_message');
      isSuccess = false;
    }
  } catch (e) {
    _message = 'Something went wrong';
    debugPrint('❌ Comments error: $e');
    isSuccess = false;
  } finally {
    isReelsCommentLoading = false;
    isCommentPaginating = false;
    update();
  }
  return isSuccess;
}

void _resetCommentPagination() {
  commentPage = 1;
  commentTotalPages = null;
  _hasMoreComments = true;
  commentsList.clear();
  commentModel = null;
}
*/
