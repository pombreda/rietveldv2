class Diffable(object):  # pylint: disable=R0921
    return utils.LazyLineSplitter(self.data_async.get_result(),
                                  self.lineending)
    raise NotImplementedError()
          for line in self.old.lines[i1:i2]:
          for line in self.old.lines[i1:i2]:
          for line in self.new.lines[j1:j2]:
    old_csum = old.git_csum_async.get_result()
    new_csum = new.git_csum_async.get_result()

      yield 'diff --git a/%s b/%s%s' % (old.path, new.path, nl)
      if old.mode != new.mode:
        yield 'index %s..%s%s' % (old_csum, new_csum, nl)
        yield 'index %s..%s %s%s' % (old_csum, new_csum, old.mode, nl)
      yield 'diff --git a/%s b/%s%s' % (new.path, new.path, nl)
      yield 'index %s..%s%s' % ('0'*40, new_csum, nl)
      yield 'diff --git a/%s b/%s%s' % (old.path, old.path, nl)
      yield 'index %s..%s%s' % (old_csum, '0'*40, nl)
      yield 'diff --git a/%s b/%s%s' % (old.path, new.path, nl)
      if old.mode != new.mode:
      yield 'similarity index %d%%%s' % (similarity * 100, nl)
        if old.mode != new.mode:
          yield 'index %s..%s%s' % (old_csum, new_csum, nl)
        else:
          yield 'index %s..%s %06o%s' % (old_csum, new_csum, old.mode, nl)